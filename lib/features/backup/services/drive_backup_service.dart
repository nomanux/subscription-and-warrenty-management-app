/// Google Drive backup & restore for all warranty data.
///
/// Backs up the Firestore `products` (what the app actually shows — see
/// [ProductService]) as a timestamped JSON file inside a visible
/// "Warantee Backups" folder in the user's Google Drive, and restores by
/// merging entries back into Firestore by id. Uses the least-privilege
/// `drive.file` scope (only files this app creates), authorized through
/// google_sign_in 7's [GoogleSignInAuthorizationClient].
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/product.dart';
import '../../../services/product_service.dart';
import '../../auth/data/google_auth_service.dart';

const String _backupFolderName = 'Warantee Backups';
const String _filePrefix = 'warantee-backup-';
const String _lastBackupKey = 'drive_last_backup_at';
const Duration _autoBackupInterval = Duration(hours: 24);

class DriveBackupService {
  DriveBackupService._();

  /// Shared singleton.
  static final DriveBackupService instance = DriveBackupService._();

  static const List<String> _scopes = [drive.DriveApi.driveFileScope];

  /// True when a Google account is connected (sign-in done).
  bool get isConnected => GoogleAuthService.instance.current != null;

  /// Back up all warranties to Google Drive. Returns the created file name.
  /// Prompts for permission if needed.
  Future<String> backupNow() => _backup(prompt: true);

  /// Restore the most recent Drive backup, merging entries by id.
  /// Returns the number of warranties restored.
  /// Prompts for permission if needed.
  Future<int> restoreLatest() => _withApi(prompt: true, (api) async {
        final folderId = await _ensureFolder(api);
        final list = await api.files.list(
          q: "'$folderId' in parents and trashed = false "
              "and name contains '$_filePrefix'",
          orderBy: 'createdTime desc',
          pageSize: 1,
          $fields: 'files(id, name)',
        );
        final files = list.files;
        if (files == null || files.isEmpty) {
          throw StateError('No backup found in Google Drive.');
        }
        final media = await api.files.get(
          files.first.id!,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;

        final bytes = <int>[];
        await for (final chunk in media.stream) {
          bytes.addAll(chunk);
        }
        final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
        final items =
            (data['products'] as List).cast<Map<String, dynamic>>();
        for (final map in items) {
          final id = map['id'] as String? ?? '';
          if (id.isEmpty) continue;
          await productService.upsertProduct(Product.fromMap(id, map));
        }
        return items.length;
      });

  /// Auto-backup once per day on app open. Silent: never shows a permission
  /// prompt and never throws (best-effort).
  Future<void> maybeAutoBackup() async {
    if (!isConnected) return;
    final last = await lastBackup();
    if (last != null &&
        DateTime.now().difference(last) < _autoBackupInterval) {
      return;
    }
    try {
      await _backup(prompt: false);
    } catch (_) {
      // Not yet authorized for Drive, offline, etc. — try again next open.
    }
  }

  /// When the last successful backup ran, or null if never.
  Future<DateTime?> lastBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastBackupKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  // ── internals ──────────────────────────────────────────────────────────────

  Future<String> _backup({required bool prompt}) =>
      _withApi(prompt: prompt, (api) async {
        try {
          debugPrint('DRIVE: starting backup...');
          final folderId = await _ensureFolder(api);
          debugPrint('DRIVE: got folder $folderId, fetching products...');
          final products = await productService.getProducts();
          debugPrint('DRIVE: got ${products.length} products, encoding...');
          final payload = <String, dynamic>{
            'schemaVersion': 1,
            'exportedAt': DateTime.now().toUtc().toIso8601String(),
            'count': products.length,
            'products': products.map((p) => p.toMap()).toList(),
          };
          final bytes = utf8.encode(jsonEncode(payload));
          debugPrint('DRIVE: payload size=${bytes.length} bytes');
          final stamp =
              DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
          final file = drive.File()
            ..name = '$_filePrefix$stamp.json'
            ..parents = [folderId];
          final media = drive.Media(
            Stream.value(bytes),
            bytes.length,
            contentType: 'application/json',
          );
          debugPrint(
              'DRIVE: uploading file ${file.name} to folder $folderId...');
          final created = await api.files.create(
            file,
            uploadMedia: media,
            $fields: 'id, name',
          );
          debugPrint('DRIVE: upload complete, id=${created.id}');
          await _setLastBackup(DateTime.now());
          return created.name ?? file.name!;
        } catch (e) {
          debugPrint('DRIVE_BACKUP_STEP_ERROR: $e');
          rethrow;
        }
      });

  /// Find (or create) the visible "Warantee Backups" folder; return its id.
  Future<String> _ensureFolder(drive.DriveApi api) async {
    debugPrint('DRIVE: listing folders...');
    try {
      final res = await api.files.list(
        q: "name = '$_backupFolderName' "
            "and mimeType = 'application/vnd.google-apps.folder' "
            "and trashed = false",
        $fields: 'files(id, name)',
      );
      final existing = res.files;
      if (existing != null && existing.isNotEmpty) {
        debugPrint('DRIVE: found folder ${existing.first.id}');
        return existing.first.id!;
      }
      debugPrint('DRIVE: folder not found, creating...');
      final folder = drive.File()
        ..name = _backupFolderName
        ..mimeType = 'application/vnd.google-apps.folder';
      final created = await api.files.create(folder, $fields: 'id');
      debugPrint('DRIVE: created folder ${created.id}');
      return created.id!;
    } catch (e) {
      debugPrint('DRIVE_FOLDER_ERROR: $e');
      rethrow;
    }
  }

  /// Build an authorized [drive.DriveApi], run [action], and close the client.
  Future<T> _withApi<T>(
    Future<T> Function(drive.DriveApi api) action, {
    required bool prompt,
  }) async {
    final account = GoogleAuthService.instance.current;
    if (account == null) {
      throw StateError('Connect a Google account first.');
    }
    final headers = await account.authorizationClient.authorizationHeaders(
      _scopes,
      promptIfNecessary: prompt,
    );
    if (headers == null) {
      throw StateError('Google Drive permission was not granted.');
    }
    final client = http.Client();
    try {
      return await action(drive.DriveApi(_AuthClient(headers, client)));
    } finally {
      client.close();
    }
  }

  Future<void> _setLastBackup(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupKey, time.toIso8601String());
  }
}

/// An [http.Client] that injects the Google authorization headers on every
/// request (the Drive API needs the bearer token on each call).
class _AuthClient extends http.BaseClient {
  _AuthClient(this._headers, this._inner);

  final Map<String, String> _headers;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

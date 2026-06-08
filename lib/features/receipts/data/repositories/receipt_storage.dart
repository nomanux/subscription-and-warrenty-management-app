/// Stores receipt image files in the app's documents directory.
///
/// The database only keeps file paths; the bytes live here on disk.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ReceiptStorage {
  static const _uuid = Uuid();

  Future<Directory> _receiptsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'receipts'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Persist [bytes] as a new file and return its absolute path.
  Future<String> saveBytes(Uint8List bytes, {String extension = 'jpg'}) async {
    final dir = await _receiptsDir();
    final path = p.join(dir.path, '${_uuid.v4()}.$extension');
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  /// Delete a receipt file (no-op if it's already gone).
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Ignore — a missing file is fine.
    }
  }
}

/// CSV backup / restore for local warranty data.
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';


class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  // ── Export to CSV ──────────────────────────────────────────────────────────

  Future<String> exportToCSV() async {
    final warranties = await _db.select(_db.warranties).get();

    if (warranties.isEmpty) {
      throw Exception('No warranties to export');
    }

    final buffer = StringBuffer();

    // CSV header
    buffer.writeln('Product Name,Category,Purchase Date,Warranty Months,Expiry Date,Store Name,Notes');

    // Data rows
    for (final w in warranties) {
      final productName = _escapeCsv(w.productName);
      final category = _escapeCsv(w.category);
      final storeName = _escapeCsv(w.storeName ?? '');
      final notes = _escapeCsv(w.notes ?? '');

      buffer.writeln(
        '$productName,$category,${w.purchaseDate.toIso8601String()},${ w.warrantyMonths},'
        '${w.expiryDate.toIso8601String()},$storeName,$notes',
      );
    }

    // Save to Downloads directory
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final filename = 'warranty_export_${now.year}-${_pad(now.month)}-${_pad(now.day)}.csv';
    final file = File('${directory.path}/$filename');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  // ── Import from CSV ────────────────────────────────────────────────────────

  Future<void> importFromCSV(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final contents = await file.readAsString();
    final lines = contents.split('\n').where((l) => l.trim().isNotEmpty).toList();

    if (lines.length < 2) {
      throw Exception('CSV file is empty or invalid');
    }

    // Skip header and parse data rows
    final dataLines = lines.skip(1);

    await _db.transaction(() async {
      for (final line in dataLines) {
        final fields = _parseCsvLine(line);
        if (fields.length < 7) continue;

        final purchaseDate = DateTime.tryParse(fields[2]);
        final expiryDate = DateTime.tryParse(fields[4]);
        final warrantyMonths = int.tryParse(fields[3]) ?? 12;

        if (purchaseDate == null || expiryDate == null) {
          continue;
        }

        await _db.into(_db.warranties).insert(
          WarrantiesCompanion.insert(
            id: 'warranty_${DateTime.now().millisecondsSinceEpoch}',
            productName: fields[0],
            category: fields[1],
            purchaseDate: purchaseDate,
            warrantyMonths: warrantyMonths,
            expiryDate: expiryDate,
            storeName: Value(fields[5].isEmpty ? null : fields[5]),
            notes: Value(fields[6].isEmpty ? null : fields[6]),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    });

    // Re-schedule notifications for imported warranties
    final warranties = await _db.select(_db.warranties).get();
    for (final w in warranties) {
      if (w.expiryDate.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleForWarranty(
          warrantyId: w.id,
          productName: w.productName,
          expiryDate: w.expiryDate,
        );
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var insideQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (insideQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (char == ',' && !insideQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    result.add(buffer.toString());
    return result;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

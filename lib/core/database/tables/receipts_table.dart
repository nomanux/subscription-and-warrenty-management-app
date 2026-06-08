/// Drift table for receipt images. Image bytes live as files on disk; this
/// stores the path. Many receipts per warranty (cascade-deleted with it).
library;

import 'package:drift/drift.dart';

import 'warranties_table.dart';

@DataClassName('ReceiptRow')
class Receipts extends Table {
  TextColumn get id => text()();
  TextColumn get warrantyId =>
      text().references(Warranties, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

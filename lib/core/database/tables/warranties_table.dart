/// Drift table for warranties. The data layer maps rows ↔ the domain Warranty.
library;

import 'package:drift/drift.dart';

@DataClassName('WarrantyRow')
class Warranties extends Table {
  TextColumn get id => text()();
  TextColumn get productName => text().withLength(min: 1, max: 200)();
  TextColumn get category => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  IntColumn get warrantyMonths => integer()();
  DateTimeColumn get expiryDate => dateTime()();
  TextColumn get storeName => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

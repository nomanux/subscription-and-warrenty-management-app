/// The Drift database — the app's local-first source of truth.
///
/// Opens an on-device SQLite file via drift_flutter. Foreign keys are enabled
/// so deleting a warranty cascades to its receipts + scheduled notifications.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/receipts_table.dart';
import 'tables/scheduled_notifications_table.dart';
import 'tables/warranties_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Warranties, Receipts, ScheduledNotifications])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests: inject an in-memory or custom executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _openConnection() => driftDatabase(name: 'warranty_vault');

/// Drift table tracking scheduled expiry notifications, so they can be
/// cancelled/rescheduled on edit and cancelled on delete.
library;

import 'package:drift/drift.dart';

import 'warranties_table.dart';

@DataClassName('ScheduledNotificationRow')
class ScheduledNotifications extends Table {
  /// The OS notification id (also the primary key).
  IntColumn get id => integer()();
  TextColumn get warrantyId =>
      text().references(Warranties, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get fireAt => dateTime()();

  /// Which reminder this is: 'd30' | 'd7' | 'expiry'.
  TextColumn get kind => text()();

  @override
  Set<Column> get primaryKey => {id};
}

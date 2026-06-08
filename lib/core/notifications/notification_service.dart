/// Local notification service — schedules warranty-expiry reminders.
///
/// Three reminders per warranty (−30 days, −7 days, on the expiry day) at
/// 9 AM local time, using stable deterministic IDs so they can be cancelled
/// and rescheduled on edit/delete. Not wired to the UI yet — the warranty
/// repository will call this on create/update/delete during the migration step.
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The reminder offsets relative to a warranty's expiry date.
enum ReminderKind {
  d30('d30', 30, 'Warranty expiring soon'),
  d7('d7', 7, 'Warranty expiring this week'),
  expiry('expiry', 0, 'Warranty expires today');

  const ReminderKind(this.key, this.daysBefore, this.headline);

  final String key;
  final int daysBefore;
  final String headline;
}

class NotificationService {
  NotificationService._();

  /// Shared singleton.
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'warranty_expiry';
  static const String _channelName = 'Warranty Reminders';
  static const String _channelDescription =
      'Reminders before your warranties expire';

  /// Fire reminders at 9 AM local time.
  static const int _reminderHour = 9;

  bool _initialized = false;

  /// Initialize timezone data + the plugin and create the Android channel.
  /// Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings: initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ));

    _initialized = true;
  }

  /// Request notification (Android 13+) and exact-alarm (Android 12+)
  /// permissions. Returns silently if already granted/unsupported.
  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  /// Deterministic notification id for a (warranty, reminder) pair.
  int _idFor(String warrantyId, ReminderKind kind) {
    final base = warrantyId.hashCode & 0x0FFFFFFF;
    return base * 4 + kind.index;
  }

  /// All notification ids belonging to a warranty (for cancel/persist).
  List<int> idsFor(String warrantyId) =>
      ReminderKind.values.map((k) => _idFor(warrantyId, k)).toList();

  /// 9 AM local time on the reminder day.
  tz.TZDateTime _fireTime(DateTime expiry, int daysBefore) {
    final day = expiry.subtract(Duration(days: daysBefore));
    return tz.TZDateTime(
        tz.local, day.year, day.month, day.day, _reminderHour);
  }

  /// (Re)schedule the three reminders for a warranty.
  ///
  /// Cancels any existing reminders for it first, then schedules only those
  /// whose fire time is still in the future.
  Future<void> scheduleForWarranty({
    required String warrantyId,
    required String productName,
    required DateTime expiryDate,
  }) async {
    await cancelForWarranty(warrantyId);

    final now = tz.TZDateTime.now(tz.local);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    for (final kind in ReminderKind.values) {
      final fireAt = _fireTime(expiryDate, kind.daysBefore);
      if (!fireAt.isAfter(now)) continue; // skip reminders already in the past

      final body = kind.daysBefore == 0
          ? '$productName warranty expires today.'
          : '$productName warranty expires in ${kind.daysBefore} days.';

      await _plugin.zonedSchedule(
        id: _idFor(warrantyId, kind),
        title: kind.headline,
        body: body,
        scheduledDate: fireAt,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: warrantyId,
      );
    }
  }

  /// Cancel all reminders for a single warranty.
  Future<void> cancelForWarranty(String warrantyId) async {
    for (final id in idsFor(warrantyId)) {
      await _plugin.cancel(id: id);
    }
  }

  /// Cancel every scheduled reminder (e.g. before a backup restore).
  Future<void> cancelAll() => _plugin.cancelAll();
}

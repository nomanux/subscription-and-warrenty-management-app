/// Core Riverpod providers: database, notifications, storage, repository.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warranty_vault/core/database/app_database.dart';
import 'package:warranty_vault/core/notifications/notification_service.dart';
import 'package:warranty_vault/features/receipts/data/repositories/receipt_storage.dart';
import 'package:warranty_vault/features/warranties/data/repositories/warranty_repository_impl.dart';
import 'package:warranty_vault/features/warranties/domain/repositories/warranty_repository.dart';

/// Overridden in main() with the loaded instance.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);

final receiptStorageProvider =
    Provider<ReceiptStorage>((ref) => ReceiptStorage());

final warrantyRepositoryProvider = Provider<WarrantyRepository>((ref) {
  return WarrantyRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(receiptStorageProvider),
  );
});

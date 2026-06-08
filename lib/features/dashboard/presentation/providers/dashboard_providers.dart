/// Derived dashboard statistics from the warranty list.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warranty_vault/features/warranties/domain/entities/warranty.dart';
import 'package:warranty_vault/features/warranties/domain/entities/warranty_status.dart';
import 'package:warranty_vault/features/warranties/presentation/providers/warranty_providers.dart';

class DashboardStats {
  const DashboardStats({
    required this.total,
    required this.active,
    required this.expiring,
    required this.expired,
    required this.expiringSoon,
    required this.nextToExpire,
  });

  final int total;
  final int active;
  final int expiring;
  final int expired;

  /// Warranties expiring within 30 days, soonest first.
  final List<Warranty> expiringSoon;

  /// The soonest warranty still within its warranty period (or null).
  final Warranty? nextToExpire;

  static const empty = DashboardStats(
    total: 0,
    active: 0,
    expiring: 0,
    expired: 0,
    expiringSoon: [],
    nextToExpire: null,
  );
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final list = ref.watch(warrantyListProvider).asData?.value;
  if (list == null || list.isEmpty) return DashboardStats.empty;

  var active = 0, expiring = 0, expired = 0;
  for (final w in list) {
    switch (w.status()) {
      case WarrantyStatus.active:
        active++;
      case WarrantyStatus.expiring:
        expiring++;
      case WarrantyStatus.expired:
        expired++;
    }
  }

  final expiringSoon = list
      .where((w) => w.status() == WarrantyStatus.expiring)
      .toList()
    ..sort((a, b) => a.daysRemaining().compareTo(b.daysRemaining()));

  final upcoming = list.where((w) => w.daysRemaining() >= 0).toList()
    ..sort((a, b) => a.daysRemaining().compareTo(b.daysRemaining()));

  return DashboardStats(
    total: list.length,
    active: active,
    expiring: expiring,
    expired: expired,
    expiringSoon: expiringSoon,
    nextToExpire: upcoming.isEmpty ? null : upcoming.first,
  );
});

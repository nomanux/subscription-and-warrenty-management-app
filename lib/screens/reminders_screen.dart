/// Reminders tab — warranties that need attention, plus local-notification sync.
///
/// Lists warranties grouped into "Expiring Soon" (within 30 days) and
/// "Expired", most-urgent first, each tappable to its detail page. As a side
/// effect, whenever the product list changes this screen (re)schedules the
/// device reminders via [NotificationService]. Notifications are mobile-only,
/// so all plugin calls are guarded behind `!kIsWeb`.
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../core/notifications/notification_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../utils/warranty.dart';
import 'product_detail_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  StreamSubscription<List<Product>>? _sub;
  List<Product>? _products;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _sub = productService.watchProducts().listen(
      (products) {
        if (!mounted) return;
        setState(() {
          _products = products;
          _error = null;
        });
        _syncNotifications(products);
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() => _error = e);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Initialize the plugin and ask for permission once (mobile only).
  Future<void> _initNotifications() async {
    if (kIsWeb) return;
    try {
      await NotificationService.instance.init();
      await NotificationService.instance.requestPermissions();
    } catch (_) {
      // Permission/plugin errors are non-fatal — the screen still works.
    }
  }

  /// Clear stale reminders and reschedule for every warranty with a future
  /// expiry. Safe to call on each stream emit (it fully resyncs).
  Future<void> _syncNotifications(List<Product> products) async {
    if (kIsWeb) return;
    try {
      final notif = NotificationService.instance;
      await notif.cancelAll();
      final now = DateTime.now();
      for (final p in products) {
        if (p.expiryDate.isEmpty) continue;
        final expiry = DateTime.tryParse(p.expiryDate);
        if (expiry == null || !expiry.isAfter(now)) continue;
        await notif.scheduleForWarranty(
          warrantyId: p.id,
          productName: p.productName,
          expiryDate: expiry,
        );
      }
    } catch (_) {
      // Scheduling failures (e.g. exact-alarm denied) shouldn't crash the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reminders',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _CenteredMessage(
        icon: HugeIcons.strokeRoundedAlertCircle,
        color: const Color(0xFFDC2626),
        title: 'Could not load reminders',
        message: '$_error',
      );
    }
    final products = _products;
    if (products == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final expiring = products
        .where((p) => p.status == WarrantyStatus.expiring)
        .toList()
      ..sort((a, b) =>
          daysRemaining(a.expiryDate).compareTo(daysRemaining(b.expiryDate)));
    final expired = products
        .where((p) => p.status == WarrantyStatus.expired)
        .toList()
      ..sort((a, b) =>
          daysRemaining(b.expiryDate).compareTo(daysRemaining(a.expiryDate)));

    if (expiring.isEmpty && expired.isEmpty) {
      return const _CenteredMessage(
        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
        color: kPrimary,
        title: "You're all caught up",
        message: 'No warranties are expiring soon. We\'ll remind you here when '
            'something needs attention.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (!kIsWeb) const _NotificationsNote(),
        if (expiring.isNotEmpty) ...[
          _SectionHeader(
            label: 'Expiring Soon',
            count: expiring.length,
            color: kStatusColors[WarrantyStatus.expiring]!,
          ),
          const SizedBox(height: 12),
          for (final p in expiring) ...[
            _ReminderTile(product: p),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
        ],
        if (expired.isNotEmpty) ...[
          _SectionHeader(
            label: 'Expired',
            count: expired.length,
            color: kStatusColors[WarrantyStatus.expired]!,
          ),
          const SizedBox(height: 12),
          for (final p in expired) ...[
            _ReminderTile(product: p),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

/// A short banner explaining when reminders fire (mobile only).
class _NotificationsNote extends StatelessWidget {
  const _NotificationsNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedNotification01,
            color: kPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "We'll notify you 30 days, 7 days, and on the day each warranty "
              'expires.',
              style: TextStyle(color: kInk, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// A section title with a count chip.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kInk,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// A single warranty row in the reminders list.
class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final color = kStatusColors[product.status]!;
    final days = daysRemaining(product.expiryDate);

    return Material(
      color: kSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailScreen(initial: product),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Expires ${_formatDate(product.expiryDate)}',
                      style: const TextStyle(color: kMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _urgencyLabel(days),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '—';
    return DateFormat('MMM d, yyyy').format(date.toLocal());
  }

  static String _urgencyLabel(int days) {
    if (days < 0) {
      final ago = -days;
      return ago == 1 ? '1 day ago' : '$ago days ago';
    }
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return 'in $days days';
  }
}

/// A full-screen centered icon + message (loading-empty / error / all-clear).
class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final List<List<dynamic>> icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kInk,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kMuted, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

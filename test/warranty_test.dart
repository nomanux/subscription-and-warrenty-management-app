// Unit tests for the warranty date math (port of the old utils.ts behavior).

import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_vault/models/product.dart';
import 'package:warranty_vault/utils/warranty.dart';

void main() {
  group('calculateExpiryDate', () {
    test('adds whole months', () {
      final expiry = calculateExpiryDate('2024-01-15T00:00:00.000Z', 12);
      expect(DateTime.parse(expiry).year, 2025);
      expect(DateTime.parse(expiry).month, 1);
    });

    test('clamps day for shorter target month (Jan 31 + 1mo -> Feb)', () {
      final expiry = calculateExpiryDate('2024-01-31T00:00:00.000Z', 1);
      final d = DateTime.parse(expiry);
      expect(d.month, 2);
      expect(d.day, lessThanOrEqualTo(29));
    });
  });

  group('computeStatus', () {
    final now = DateTime(2026, 6, 8);

    test('expired when past expiry', () {
      final expiry = '2026-06-01T00:00:00.000Z';
      expect(computeStatus(expiry, now), WarrantyStatus.expired);
    });

    test('expiring when within 30 days', () {
      final expiry = '2026-06-20T00:00:00.000Z';
      expect(computeStatus(expiry, now), WarrantyStatus.expiring);
    });

    test('active when far from expiry', () {
      final expiry = '2027-01-01T00:00:00.000Z';
      expect(computeStatus(expiry, now), WarrantyStatus.active);
    });
  });
}

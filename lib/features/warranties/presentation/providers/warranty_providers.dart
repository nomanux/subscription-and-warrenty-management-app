/// Presentation providers for warranties.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warranty_vault/core/providers/app_providers.dart';
import 'package:warranty_vault/features/warranties/domain/entities/warranty.dart';

/// Reactive list of all warranties (auto-updates on any DB change).
final warrantyListProvider = StreamProvider<List<Warranty>>((ref) {
  return ref.watch(warrantyRepositoryProvider).watchAll();
});

/// A single warranty by id (re-fetched when the list changes).
final warrantyByIdProvider =
    FutureProvider.family<Warranty?, String>((ref, id) {
  ref.watch(warrantyListProvider);
  return ref.watch(warrantyRepositoryProvider).getById(id);
});

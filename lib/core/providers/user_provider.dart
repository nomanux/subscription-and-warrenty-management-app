import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart';

class _UserNotifier extends AsyncNotifier<User> {
  static const String _key = 'user_profile';

  @override
  Future<User> build() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
    return User();
  }

  Future<void> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
    state = AsyncValue.data(user);
  }

  Future<void> updateName(String name) async {
    final current = await future;
    await updateUser(current.copyWith(name: name));
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    final current = await future;
    await updateUser(current.copyWith(phoneNumber: phoneNumber));
  }

  Future<void> updateProfileImage(String imagePath) async {
    final current = await future;
    await updateUser(current.copyWith(profileImagePath: imagePath));
  }
}

final userProvider = AsyncNotifierProvider<_UserNotifier, User>(_UserNotifier.new);

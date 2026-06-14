library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user_auth_service.dart';

final userAuthServiceProvider = Provider<UserAuthService>((ref) {
  return UserAuthService.instance;
});

class UserAuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? username;
  final String? email;
  final bool isGoogleLogin;
  final bool isLoading;
  final String? error;

  UserAuthState({
    this.isLoggedIn = false,
    this.userId,
    this.username,
    this.email,
    this.isGoogleLogin = false,
    this.isLoading = false,
    this.error,
  });

  UserAuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? username,
    String? email,
    bool? isGoogleLogin,
    bool? isLoading,
    String? error,
  }) {
    return UserAuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      isGoogleLogin: isGoogleLogin ?? this.isGoogleLogin,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserAuthNotifier extends Notifier<UserAuthState> {
  late final UserAuthService _service;

  @override
  UserAuthState build() {
    _service = ref.watch(userAuthServiceProvider);
    return UserAuthState();
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.login(username, password);
      state = state.copyWith(
        isLoggedIn: true,
        userId: _service.currentUserId,
        username: _service.currentUsername,
        email: username, // Store email from login
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', '').replaceAll('StateError: ', ''),
      );
    }
  }

  Future<void> signup(
    String username,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.signup(username, email, password, passwordConfirm);
      state = state.copyWith(
        isLoggedIn: true,
        userId: _service.currentUserId,
        username: _service.currentUsername,
        email: email,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', '').replaceAll('StateError: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = UserAuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> setGoogleLogin(dynamic googleAccount) async {
    state = state.copyWith(
      isLoggedIn: true,
      isGoogleLogin: true,
      userId: googleAccount.email, // Use email as unique ID
      email: googleAccount.email,
      username: googleAccount.displayName,
    );
  }
}

final userAuthStateProvider = NotifierProvider<UserAuthNotifier, UserAuthState>(
  UserAuthNotifier.new,
);

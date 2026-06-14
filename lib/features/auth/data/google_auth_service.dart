/// Google sign-in wrapper (google_sign_in 7.2.0) — Android only for now.
///
/// "Optional connect" model: the app is fully usable without signing in. This
/// service is only exercised when the user explicitly connects a Google account
/// (the foundation for the upcoming Google Drive backup/sync). On web the
/// interactive flow isn't wired up, so [isSupported] is false and every call is
/// a safe no-op.
///
/// google_sign_in 7.x reports the signed-in account through a broadcast
/// [GoogleSignIn.authenticationEvents] stream that does NOT replay. We therefore
/// cache the latest account here and replay it to new listeners, so a screen
/// opened after the startup silent-restore still sees the correct state.
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  /// Shared singleton.
  static final GoogleAuthService instance = GoogleAuthService._();

  /// Interactive Google sign-in is only available on Android in this build.
  bool get isSupported => !kIsWeb;

  bool _initialized = false;
  GoogleSignInAccount? _current;
  final StreamController<GoogleSignInAccount?> _accounts =
      StreamController<GoogleSignInAccount?>.broadcast();

  /// The most recently known account (null when signed out / unsupported).
  GoogleSignInAccount? get current => _current;

  /// Initialize the plugin once and silently restore any prior session.
  ///
  /// Non-fatal by contract: the caller wraps this in a try/catch at startup.
  Future<void> init() async {
    if (!isSupported || _initialized) return;

    await GoogleSignIn.instance.initialize();
    _initialized = true;

    // Keep [_current] in sync for the lifetime of the app.
    GoogleSignIn.instance.authenticationEvents.listen(
      (event) {
        _current = switch (event) {
          GoogleSignInAuthenticationEventSignIn(:final user) => user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };
        _accounts.add(_current);
      },
      onError: (_) {
        _current = null;
        _accounts.add(null);
      },
    );

    // Fires a sign-in event through [authenticationEvents] if a session exists.
    final attempt = GoogleSignIn.instance.attemptLightweightAuthentication();
    if (attempt != null) {
      try {
        await attempt;
      } catch (_) {
        // No restorable session — stay signed out.
      }
    }
  }

  /// Current account replayed to new listeners, then every subsequent change.
  Stream<GoogleSignInAccount?> accountChanges() async* {
    yield _current;
    yield* _accounts.stream;
  }

  /// Interactive sign-in. Returns the account, or null if the user cancelled.
  Future<GoogleSignInAccount?> signIn() async {
    if (!isSupported || !GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError('Google sign-in is only available on Android.');
    }
    try {
      return await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  /// Sign out (keeps the account authorized for quick re-sign-in).
  Future<void> signOut() async {
    if (!isSupported) return;
    await GoogleSignIn.instance.signOut();
  }

  /// Fully disconnect and revoke access.
  Future<void> disconnect() async {
    if (!isSupported) return;
    await GoogleSignIn.instance.disconnect();
  }
}

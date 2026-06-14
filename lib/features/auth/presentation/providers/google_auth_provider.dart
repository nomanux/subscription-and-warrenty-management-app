/// Riverpod providers exposing the connected Google account.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/google_auth_service.dart';

/// The shared [GoogleAuthService].
final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (ref) => GoogleAuthService.instance,
);

/// The currently signed-in Google account, or null when signed out.
final googleAccountProvider = StreamProvider<GoogleSignInAccount?>(
  (ref) => ref.watch(googleAuthServiceProvider).accountChanges(),
);

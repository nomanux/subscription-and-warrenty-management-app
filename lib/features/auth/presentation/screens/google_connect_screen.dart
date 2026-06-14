/// "Connect Google Account" portal.
///
/// Optional sign-in used to enable Google Drive backup later. Shows a connect
/// button when signed out, and the connected account (avatar / name / email)
/// with a disconnect action when signed in. On web (where the interactive flow
/// isn't wired up) it shows an "Android only" notice instead.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../theme.dart';
import '../providers/google_auth_provider.dart';
import '../providers/user_auth_provider.dart';

class GoogleConnectScreen extends ConsumerStatefulWidget {
  const GoogleConnectScreen({super.key});

  @override
  ConsumerState<GoogleConnectScreen> createState() =>
      _GoogleConnectScreenState();
}

class _GoogleConnectScreenState extends ConsumerState<GoogleConnectScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(googleAuthServiceProvider).signIn();
      final account = ref.read(googleAuthServiceProvider).current;
      if (account != null && mounted) {
        // Mark user as Google login so profile displays Google data
        ref.read(userAuthStateProvider.notifier).setGoogleLogin(account);
      }
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(googleAuthServiceProvider).disconnect();
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object e) {
    if (e is GoogleSignInException) {
      return 'Sign-in failed (${e.code.name}). '
          'Make sure Google sign-in is configured for this app.';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(googleAuthServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Google Account')),
      body: SafeArea(
        child: !service.isSupported
            ? const _UnsupportedNotice()
            : ref.watch(googleAccountProvider).when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _SignedOut(
                    busy: _busy,
                    error: _friendlyError(e),
                    onSignIn: _signIn,
                  ),
                  data: (account) => account == null
                      ? _SignedOut(
                          busy: _busy,
                          error: _error,
                          onSignIn: _signIn,
                        )
                      : _SignedIn(
                          account: account,
                          busy: _busy,
                          error: _error,
                          onDisconnect: _disconnect,
                        ),
                ),
      ),
    );
  }
}

/// Signed-out state: explanation + a "Sign in with Google" button.
class _SignedOut extends StatelessWidget {
  const _SignedOut({
    required this.busy,
    required this.error,
    required this.onSignIn,
  });

  final bool busy;
  final String? error;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedGoogleDrive,
                color: kPrimary,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Connect your Google account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kInk,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in with Google to back up your warranties to Google Drive. '
            'Your data stays on this device until you connect.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kMuted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),
          if (error != null) ...[
            _ErrorBanner(message: error!),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: busy ? null : onSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: kSurface,
                foregroundColor: kInk,
                elevation: 1.5,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedGoogle,
                          color: kInk,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Signed-in state: account card + disconnect.
class _SignedIn extends StatelessWidget {
  const _SignedIn({
    required this.account,
    required this.busy,
    required this.error,
    required this.onDisconnect,
  });

  final GoogleSignInAccount account;
  final bool busy;
  final String? error;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final photoUrl = account.photoUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: kCardShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kPrimary.withValues(alpha: 0.12),
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? HugeIcon(
                          icon: HugeIcons.strokeRoundedUserCircle,
                          color: kPrimary,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.displayName ?? 'Google account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: kPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Connected — ready for Google Drive backup.',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (error != null) ...[
            _ErrorBanner(message: error!),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: busy ? null : onDisconnect,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Disconnect',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown on web, where the interactive sign-in flow isn't available.
class _UnsupportedNotice extends StatelessWidget {
  const _UnsupportedNotice();

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
                color: kMuted.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedGoogle,
                color: kMuted,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Not available on web',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kInk,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Open the Android app to connect your Google account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlertCircle,
            color: const Color(0xFFDC2626),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

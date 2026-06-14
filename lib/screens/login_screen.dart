/// Google Sign-in login screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hugeicons/hugeicons.dart';

import '../features/auth/data/google_auth_service.dart';
import '../features/auth/presentation/providers/user_auth_provider.dart';
import '../theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _signingIn = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _signingIn = true;
      _error = null;
    });

    try {
      await GoogleAuthService.instance.signIn();
      final account = GoogleAuthService.instance.current;
      if (account != null && mounted) {
        // Mark as Google login and navigate to home
        ref.read(userAuthStateProvider.notifier).setGoogleLogin(account);
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _friendlyError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _signingIn = false);
      }
    }
  }

  String _friendlyError(Object e) {
    if (e is GoogleSignInException) {
      return 'Sign-in failed. Make sure Google sign-in is configured for this app.';
    }
    return 'Sign-in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedFile01,
                  color: kPrimary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Warantee',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Track. Store. Never Miss.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              const Text(
                'Manage all your warranties in one place. Get reminders before they expire.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),

              // Error message
              if (_error != null) ...[
                Container(
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
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Google Sign-in Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _signingIn ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: kPrimary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _signingIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : HugeIcon(
                          icon: HugeIcons.strokeRoundedGoogle,
                          color: Colors.white,
                          size: 22,
                        ),
                  label: Text(
                    _signingIn ? 'Signing in...' : 'Sign in with Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Benefits
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kMuted.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BenefitRow(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      text: 'Sync across devices',
                    ),
                    const SizedBox(height: 12),
                    _BenefitRow(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      text: 'Automatic Drive backup',
                    ),
                    const SizedBox(height: 12),
                    _BenefitRow(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      text: 'Never lose your data',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Privacy notice
              Text(
                'By signing in, you agree to our privacy policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: kMuted,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  final List<List<dynamic>> icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          color: kPrimary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: kInk,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

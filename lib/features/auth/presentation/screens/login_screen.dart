/// Modern, clean login screen inspired by TheFork.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme.dart';
import '../../data/google_auth_service.dart';
import '../providers/user_auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({required this.onLoginSuccess, super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLogin = true;

  // For signup
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupPasswordConfirmController = TextEditingController();
  bool _showSignupPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupPasswordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    await ref.read(userAuthStateProvider.notifier).login(email, password);

    if (mounted) {
      final authState = ref.read(userAuthStateProvider);
      if (authState.isLoggedIn) {
        widget.onLoginSuccess();
      } else if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _handleSignup() async {
    final email = _signupEmailController.text.trim();
    final password = _signupPasswordController.text;
    final passwordConfirm = _signupPasswordConfirmController.text;

    await ref.read(userAuthStateProvider.notifier).signup(
          email,
          email,
          password,
          passwordConfirm,
        );

    if (mounted) {
      final authState = ref.read(userAuthStateProvider);
      if (authState.isLoggedIn) {
        widget.onLoginSuccess();
      } else if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Initialize Google Sign-In if not already initialized
      await GoogleAuthService.instance.init();

      // Then sign in
      await GoogleAuthService.instance.signIn();
      if (mounted) {
        final account = GoogleAuthService.instance.current;
        if (account != null) {
          // Mark this as a Google login
          await ref.read(userAuthStateProvider.notifier).setGoogleLogin(account);
          widget.onLoginSuccess();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(userAuthStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: kInk, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person, color: kPrimary, size: 28),
              ),
              const SizedBox(height: 32),

              // Welcome Text
              Text(
                _isLogin ? 'Welcome to Warantee' : 'Create Account',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              // Content based on login/signup
              if (_isLogin) _buildLoginForm(authState) else _buildSignupForm(authState),

              const SizedBox(height: 24),

              // Social divider
              Row(
                children: [
                  Expanded(child: Divider(color: kMuted.withValues(alpha: 0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: kMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: kMuted.withValues(alpha: 0.2))),
                ],
              ),
              const SizedBox(height: 20),

              // Google button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                  icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kInk,
                    side: BorderSide(color: kMuted.withValues(alpha: 0.2), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle between login and signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? "Don't have an account? " : 'Already have an account? ',
                    style: TextStyle(color: kMuted, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Sign up' : 'Login',
                      style: const TextStyle(
                        color: kPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(UserAuthState authState) {
    return Column(
      children: [
        // Email field
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email *',
            hintText: 'your@email.com',
            prefixIcon: Icon(Icons.email, color: kMuted, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
          enabled: !authState.isLoading,
        ),
        const SizedBox(height: 16),

        // Password field
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock, color: kMuted, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: kMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
          enabled: !authState.isLoading,
        ),
        const SizedBox(height: 12),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: authState.isLoading ? null : () {},
            child: Text(
              'Forgot your password?',
              style: TextStyle(
                color: kPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: authState.isLoading ? null : _handleLogin,
            style: FilledButton.styleFrom(
              backgroundColor: kPrimary,
              disabledBackgroundColor: kPrimary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        // Error message
        if (authState.error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFDC2626).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFFDC2626).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authState.error!,
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSignupForm(UserAuthState authState) {
    return Column(
      children: [
        // Email field
        TextField(
          controller: _signupEmailController,
          decoration: InputDecoration(
            labelText: 'Email *',
            hintText: 'your@email.com',
            prefixIcon: Icon(Icons.email, color: kMuted, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
          enabled: !authState.isLoading,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Password field
        TextField(
          controller: _signupPasswordController,
          obscureText: !_showSignupPassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock, color: kMuted, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _showSignupPassword ? Icons.visibility_off : Icons.visibility,
                color: kMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _showSignupPassword = !_showSignupPassword),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
          enabled: !authState.isLoading,
        ),
        const SizedBox(height: 16),

        // Confirm password field
        TextField(
          controller: _signupPasswordConfirmController,
          obscureText: !_showSignupPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password *',
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock, color: kMuted, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kMuted.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
          enabled: !authState.isLoading,
        ),
        const SizedBox(height: 24),

        // Sign up button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: authState.isLoading ? null : _handleSignup,
            style: FilledButton.styleFrom(
              backgroundColor: kPrimary,
              disabledBackgroundColor: kPrimary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        // Error message
        if (authState.error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFDC2626).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFFDC2626).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authState.error!,
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

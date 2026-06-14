/// Splash screen shown on app startup.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Show splash for 3 seconds, then transition
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with scale animation
            ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              ),
              child: SvgPicture.asset(
                'assets/w.svg',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 32),

            // App name
            const Text(
              'Warantee',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: kInk,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Track. Store. Never Miss.',
              style: TextStyle(
                fontSize: 14,
                color: kMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),

            // Loading spinner
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: kPrimary.withValues(alpha: 0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

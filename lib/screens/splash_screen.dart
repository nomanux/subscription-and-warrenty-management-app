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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
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
            // Logo with zoom animation
            ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.1).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
          ],
        ),
      ),
    );
  }
}

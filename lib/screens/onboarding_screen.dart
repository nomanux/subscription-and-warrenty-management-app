/// First-time user onboarding flow.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _OnboardingPage(
                  title: 'Welcome to Warantee',
                  subtitle: 'Never lose track of your warranties again',
                  icon: '📋',
                  description:
                      'Keep all your product warranties in one safe place, organized and easy to find.',
                ),
                _OnboardingPage(
                  title: 'Stay on Top',
                  subtitle: 'Get alerts before warranties expire',
                  icon: '⏰',
                  description:
                      'Receive notifications when your warranties are about to expire so you never miss coverage.',
                ),
                _OnboardingPage(
                  title: 'Quick Overview',
                  subtitle: 'See your warranty status at a glance',
                  icon: '📊',
                  description:
                      'The dashboard gives you a quick summary of all your warranties and what\'s expiring soon.',
                ),
                _OnboardingPage(
                  title: 'Easy to Use',
                  subtitle: 'Add warranties in seconds',
                  icon: '✨',
                  description:
                      'Simply tap the + button and fill in the details. You\'re all set to manage your warranties!',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? kPrimary : kMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back'),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _completeOnboarding,
                          child: const Text('Skip'),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (_currentPage == 3) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == 3 ? 'Get Started' : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: kInk,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: kMuted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

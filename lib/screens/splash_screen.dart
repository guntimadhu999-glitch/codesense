import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    await _fade.reverse();
    if (!mounted) return;
    final seen = StorageService.instance.seenOnboarding;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => seen ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.midnightGradient),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('CodeSense 🔍',
                      style: AppTheme.ui(
                          size: 34,
                          weight: FontWeight.w700,
                          color: AppColors.cyan)),
                  AnimatedBuilder(
                    animation: _bounce,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, -12 * _bounce.value),
                      child: child,
                    ),
                    child: const Text('⚡', style: TextStyle(fontSize: 32)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Write better code, ship with confidence',
                style: AppTheme.ui(size: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

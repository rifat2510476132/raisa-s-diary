import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/particle_background.dart';
import '../widgets/tahsin_avatar.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final storage = ref.read(storageProvider);
    final onboarding = await storage.isOnboardingDone();
    if (!mounted) return;
    if (!onboarding) {
      context.go('/onboarding');
      return;
    }
    await ref.read(authStateProvider.notifier).checkAuth();
    if (!mounted) return;
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth?.isAuthenticated == true) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TahsinAvatar(size: 100, pulsing: true),
              const SizedBox(height: 32),
              Text(
                "Raisa's Diary",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.pink,
                    ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'with Tahsin 💕',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.pinkLight
                          : AppColors.pink,
                    ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: AppColors.pink),
            ],
          ),
        ),
      ),
    );
  }
}

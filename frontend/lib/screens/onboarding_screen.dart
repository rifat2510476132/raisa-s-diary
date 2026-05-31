import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/particle_background.dart';
import '../widgets/tahsin_avatar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      title: 'Your Safe Space',
      subtitle: 'Write every feeling — happiness, sadness, dreams, confessions. Only you and Tahsin.',
      emoji: '📔',
    ),
    _OnboardPage(
      title: 'Meet Tahsin',
      subtitle: 'Your caring AI partner who motivates, protects, and loves you through every word.',
      emoji: '💕',
    ),
    _OnboardPage(
      title: 'Grow Together',
      subtitle: 'Track emotions, build streaks, unlock achievements, and feel emotionally alive.',
      emoji: '✨',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _pages[i],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? AppColors.pink : AppColors.pinkLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_page < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        final container = ProviderScope.containerOf(context);
                        await container.read(storageProvider).setOnboardingDone();
                        if (context.mounted) context.go('/register');
                      }
                    },
                    child: Text(_page < _pages.length - 1 ? 'Next' : 'Begin Your Diary'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.title, required this.subtitle, required this.emoji});

  final String title;
  final String subtitle;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emoji == '💕') const TahsinAvatar(size: 120) else Text(emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

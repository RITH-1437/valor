import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.style_outlined,
      title: 'Discover Premium Fashion',
      subtitle: 'Explore curated collections from the world\'s most prestigious fashion brands. Elevate your style with VALOR.',
      color: Color(0xFFD4AF37),
    ),
    _OnboardingSlide(
      icon: Icons.fitbit_outlined,
      title: 'AI-Powered Size Recommendations',
      subtitle: 'Never worry about the wrong fit again. Our smart AI analyzes your measurements to recommend the perfect size every time.',
      color: Color(0xFF6C63FF),
    ),
    _OnboardingSlide(
      icon: Icons.map_outlined,
      title: 'Find Stores Near You',
      subtitle: 'Locate the nearest VALOR store with interactive maps. Visit us for a personalized styling experience.',
      color: Color(0xFF00C9A7),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _currentPage < 2 ? () => _pageController.animateToPage(2, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut) : null,
                child: Text(_currentPage < 2 ? 'Skip' : '', style: const TextStyle(color: AppTheme.gray, fontSize: 16)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (ctx, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: slide.color.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon, size: 64, color: slide.color),
                        ),
                        const SizedBox(height: 48),
                        Text(slide.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                        const SizedBox(height: 16),
                        Text(slide.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppTheme.gray, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? AppTheme.gold : AppTheme.darkGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _currentPage == 2 ? _completeOnboarding : () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                      child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _OnboardingSlide({required this.icon, required this.title, required this.subtitle, required this.color});
}

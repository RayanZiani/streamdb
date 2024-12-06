import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header_widget.dart';
import '../providers/theme_providers.dart';
import '../constants/theme_constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _animationController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCarouselSlide({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
              stops: const [0.2, 0.8],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Animated patterns
                ...List.generate(3, (index) {
                  return Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 2 * 3.14159 * (index + 1),
                          child: Opacity(
                            opacity: 0.05,
                            child: Icon(
                              icon,
                              size: 200 + (index * 100),
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final colors = themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(
                  title: 'Découvrez',
                  subtitle: 'Votre nouvelle plateforme de streaming',
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 320,
                          child: PageView(
                            controller: _pageController,
                            children: [
                              _buildCarouselSlide(
                                title: 'StreamDB\nLe streaming réinventé',
                                description: 'Une expérience cinématographique inégalée en 4K HDR avec Dolby Atmos.',
                                icon: Icons.auto_awesome,
                                gradientColors: [
                                  colors.headerGradientStart,
                                  colors.headerGradientMiddle,
                                ],
                              ),
                              _buildCarouselSlide(
                                title: 'Un catalogue\nsans limites',
                                description: 'Des milliers de films et séries, enrichis quotidiennement pour votre plaisir.',
                                icon: Icons.movie_creation,
                                gradientColors: [
                                  colors.primary,
                                  colors.secondary,
                                ],
                              ),
                              _buildCarouselSlide(
                                title: 'Pack Opening\nPersonnalisé',
                                description: 'Découvrez des contenus parfaitement adaptés à vos goûts grâce à notre IA.',
                                icon: Icons.rocket_launch,
                                gradientColors: [
                                  colors.accent,
                                  colors.primary,
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: 3,
                            effect: WormEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              spacing: 8,
                              activeDotColor: colors.primary,
                              dotColor: colors.primary.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

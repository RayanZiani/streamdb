import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';
import '../models/card_data.dart';
import '../constants/theme_constants.dart';
import '../widgets/header_widget.dart';
import '../widgets/booster_modal.dart';
import 'dart:ui';
import 'dart:math';

class CasinoScreen extends StatefulWidget {
  const CasinoScreen({Key? key}) : super(key: key);

  @override
  State<CasinoScreen> createState() => _CasinoScreenState();
}

class _CasinoScreenState extends State<CasinoScreen> with TickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  List<Movie> _trendingContent = [];
  String _randomGenre = '';
  bool _isLoading = true;
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnimations;
  late final List<Animation<double>> _glowAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadContent();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 2000 + (index * 200)),
        vsync: this,
      )..repeat(reverse: true),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
      );
    }).toList();

    _glowAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
      );
    }).toList();

    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final genres = await _movieService.getGenres();
      final randomGenre = genres[Random().nextInt(genres.length)];
      final content = await _movieService.getTrendingContent();
      
      setState(() {
        _trendingContent = content;
        _randomGenre = randomGenre['name'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark 
      ? AppColors.dark 
      : AppColors.light;

    final List<CardData> cardData = [
      CardData(title: 'Films 2024', tag: 'FILMS'),
      CardData(title: 'Séries 2024', tag: 'SÉRIES'),
      CardData(title: 'Aléatoire', tag: '? ? ?'),
      CardData(title: _randomGenre, tag: '? ? ?'),
    ];

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(
              title: 'Casino',
              subtitle: 'Quel sera votre prochain visionnage?',
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: _buildShimmerLoader(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          if (index >= _trendingContent.length) return const SizedBox();
                          return ContentCard(
                            content: _trendingContent[index],
                            cardData: cardData[index],
                            scaleAnimation: _scaleAnimations[index],
                            glowAnimation: _glowAnimations[index],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    final theme = Theme.of(context).brightness == Brightness.dark 
        ? AppColors.dark 
        : AppColors.light;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(0.5),
            theme.secondary.withOpacity(0.3),
            theme.primary.withOpacity(0.5),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CircularProgressIndicator(
          color: theme.text,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  final Movie content;
  final CardData cardData;
  final Animation<double> scaleAnimation;
  final Animation<double> glowAnimation;

  const ContentCard({
    Key? key,
    required this.content,
    required this.cardData,
    required this.scaleAnimation,
    required this.glowAnimation,
  }) : super(key: key);

  void _showBoosterModal(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark 
        ? AppColors.dark 
        : AppColors.light;
        
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: theme.background.withOpacity(0.87),
      builder: (BuildContext context) {
        return BoosterModal(
          cardData: cardData,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark 
        ? AppColors.dark 
        : AppColors.light;

    return GestureDetector(
      onTap: () => _showBoosterModal(context),
      child: AnimatedBuilder(
        animation: Listenable.merge([scaleAnimation, glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.3 * glowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: theme.accent.withOpacity(0.2 * glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (content.posterPath != null)
                      Image.network(
                        MovieService.getImageUrl(content.posterPath!),
                        fit: BoxFit.cover,
                      ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.headerGradientStart.withOpacity(0.8),
                              theme.headerGradientMiddle.withOpacity(0.6),
                              theme.headerGradientEnd.withOpacity(0.9),
                            ],
                            stops: const [0.2, 0.5, 0.8],
                          ),
                        ),
                        child: CustomPaint(
                          painter: GlowingGridPainter(
                            glowOpacity: glowAnimation.value * 0.3,
                            primaryColor: theme.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              theme.background.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cardData.title,
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: theme.primary.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                  Shadow(
                                    color: theme.background.withOpacity(0.54),
                                    blurRadius: 3,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                                border: Border.all(
                                  color: theme.text.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                cardData.tag,
                                style: TextStyle(
                                  color: theme.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
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
            ),
          );
        },
      ),
    );
  }
}

class GlowingGridPainter extends CustomPainter {
  final double glowOpacity;
  final Color primaryColor;

  GlowingGridPainter({required this.glowOpacity, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(glowOpacity * 0.1)
      ..strokeWidth = 0.5;

    const spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GlowingGridPainter oldDelegate) {
    return oldDelegate.glowOpacity != glowOpacity;
  }
}
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moviedb/models/movie.dart';
import 'package:moviedb/services/movie_service.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;
import '../constants/theme_constants.dart';
import '../models/card_data.dart';

class EnhancedParticle {
  double angle;
  double radius;
  double speed;
  double size;
  double opacity;
  double rotationSpeed;
  double pulsation;

  EnhancedParticle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.rotationSpeed,
    required this.pulsation,
  });
}

class BoosterModal extends StatefulWidget {
  final CardData cardData;
  final VoidCallback onClose;

  const BoosterModal({
    Key? key,
    required this.cardData,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BoosterModal> createState() => _BoosterModalState();
}

class _BoosterModalState extends State<BoosterModal> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _shineController;
  late AnimationController _particleController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  final List<EnhancedParticle> _particles = [];
  final math.Random _random = math.Random();

 List<RevealedCard> _revealedCards = [];
  bool _isRevealing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateEnhancedParticles();
    _prepareCards();
  }

  Future<void> _prepareCards() async {  
    final MovieService _movieService = MovieService();
    List<Movie> selectedMovies = [];

    switch (widget.cardData.tag) {
      case 'FILMS':
        selectedMovies = await _movieService.getTopMovies2024();
        break;
      case 'SÉRIES':
        selectedMovies = await _movieService.getTopTVShows2024();
        break;
       case '? ? ?':
          if (widget.cardData.title == 'Aléatoire') {
            // Récupérer du contenu tendance mélangé
            selectedMovies = await _movieService.getTrendingContent();
          } else {
            // Pour le genre spécifique
            final genres = await _movieService.getGenres();
            final genre = genres.firstWhere(
              (g) => g['name'] == widget.cardData.title,
              orElse: () => {'id': -1},
            );
            if (genre['id'] != -1) {
              selectedMovies = await _movieService.getContentByGenre(genre['id']);
            }
          }
          break;
      }

    // Mélanger et prendre 3 éléments
    selectedMovies.shuffle();
    selectedMovies = selectedMovies.take(3).toList();

    // Créer les animations pour chaque carte
    _revealedCards = selectedMovies.map((movie) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      return RevealedCard(
        movie: movie,
        controller: controller,
        scaleAnimation: Tween<double>(begin: 0.3, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.elasticOut),
        ),
        rotateAnimation: Tween<double>(
          begin: -0.5,
          end: 0.0,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack)),
        opacityAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeIn),
        ),
      );
    }).toList();
  }

  Future<void> _revealCards() async {
    if (_isRevealing) return;
    _isRevealing = true;

    // Animer la carte principale pour disparaître
    await _scaleController.reverse();

    // Révéler les cartes une par une
    for (int i = 0; i < _revealedCards.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _revealedCards[i].controller.forward();
    }
  }


  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _shineController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleController.forward();
    _startShineAnimation();
  }

  void _startShineAnimation() {
    if (mounted) {
      _shineController.repeat();
    }
  }

  void _generateEnhancedParticles() {
    for (int i = 0; i < 35; i++) {
      _particles.add(EnhancedParticle(
        angle: _random.nextDouble() * 360,
        radius: _random.nextDouble() * 150 + 50,
        speed: _random.nextDouble() * 1.5 + 0.5,
        size: _random.nextDouble() * 4 + 2,
        opacity: _random.nextDouble() * 0.5 + 0.5,
        rotationSpeed: _random.nextDouble() * 2 - 1,
        pulsation: _random.nextDouble() * 0.3 + 0.7,
      ));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shineController.dispose();
    _particleController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context).brightness == Brightness.dark 
      ? AppColors.dark 
      : AppColors.light;

  return GestureDetector(
    onTap: _revealCards,
    child: ScaleTransition(
      scale: _scaleController,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
              if (!_isRevealing) ... [
                          // Effet de particules en arrière-plan
              AnimatedBuilder(
                animation: Listenable.merge([
                  _rotationController,
                  _particleController,
                  _pulseController
                ]),
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(300, 400),
                    painter: EnhancedStarFieldPainter(
                      particles: _particles,
                      animation: _particleController.value,
                      rotationValue: _rotationController.value,
                      pulseValue: _pulseController.value,
                      color: theme.text,
                    ),
                  );
                },
              ),
              // Carte principale avec effet 3D
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(math.sin(_pulseController.value * math.pi) * 0.1)
                      ..rotateX(math.cos(_pulseController.value * math.pi) * 0.05),
                    alignment: FractionalOffset.center,
                    child: Container(
                      width: 250,
                      height: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.headerGradientStart.withOpacity(0.9),
                            theme.headerGradientMiddle,
                            theme.headerGradientEnd.withOpacity(0.9),
                          ],
                          stops: const [0.2, 0.5, 0.8],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(
                              math.sin(_pulseController.value * math.pi) * 5,
                              math.cos(_pulseController.value * math.pi) * 5,
                            ),
                          ),
                          BoxShadow(
                            color: theme.accent.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(
                              -math.sin(_pulseController.value * math.pi) * 3,
                              -math.cos(_pulseController.value * math.pi) * 3,
                            ),
                          ),
                        ],
                        border: Border.all(
                          color: theme.text.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Nouvel effet de brillance amélioré
                          AnimatedBuilder(
                            animation: _shineController,
                            builder: (context, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CustomPaint(
                                  size: const Size(250, 350),
                                  painter: ImprovedShinePainter(
                                    animation: _shineController.value,
                                    color: theme.text,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Titre de la carte
                          Center(
                            child: Text(
                              widget.cardData.title,
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: theme.primary.withOpacity(0.5 + _pulseController.value * 0.3),
                                    blurRadius: 10 + _pulseController.value * 5,
                                  ),
                                  Shadow(
                                    color: theme.background.withOpacity(0.45),
                                    blurRadius: 15,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            
            ],
            
          // Les cartes révélées
          ..._revealedCards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            
            return AnimatedBuilder(
              animation: Listenable.merge([
                card.controller,
              ]),
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width * (0.2 + index * 0.25),
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(card.rotateAnimation.value)
                      ..scale(card.scaleAnimation.value),
                    alignment: FractionalOffset.center,
                    child: Opacity(
                      opacity: card.opacityAnimation.value,
                      child: MovieCard(
                        movie: card.movie,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    )));
  }
}

// Widget pour afficher une carte de film/série
class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.posterPath != null)
              Image.network(
                MovieService.getImageUrl(movie.posterPath!),
                fit: BoxFit.cover,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colorScheme.background.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                movie.title,
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevealedCard {
  final Movie movie;
  final AnimationController controller;
  final Animation<double> scaleAnimation;
  final Animation<double> rotateAnimation;
  final Animation<double> opacityAnimation;

  RevealedCard({
    required this.movie,
    required this.controller,
    required this.scaleAnimation,
    required this.rotateAnimation,
    required this.opacityAnimation,
  });
}


class ImprovedShinePainter extends CustomPainter {
  final double animation;
  final Color color;

  ImprovedShinePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // On étend la zone de dessin au-delà des dimensions de la carte
    final extendedWidth = size.width * 3; // Zone trois fois plus large
    final offset = -size.width; // Décalage négatif pour commencer hors de la carte
    
    // Position étendue pour que le reflet traverse complètement
    final basePosition = animation * 4 - 2.0; // Amplitude augmentée pour couvrir la zone étendue
    final slowWave = math.sin(animation * math.pi * 2) * 0.3;
    final fastWave = math.sin(animation * math.pi * 4) * 0.1;
    final combinedPosition = basePosition + slowWave + fastWave;
    
    // Variation d'intensité
    final intensity = (math.cos(animation * math.pi * 2) * 0.3 + 0.7)
        * (0.8 + math.sin(animation * math.pi * 3) * 0.2);

    // Gradient principal étendu
    final mainGradient = LinearGradient(
      begin: Alignment(combinedPosition - 0.2, -0.2),
      end: Alignment(combinedPosition + 0.2, 0.2),
      colors: [
        color.withOpacity(0),
        color.withOpacity(0.05 * intensity),
        color.withOpacity(0.1 * intensity),
        Colors.white.withOpacity(0.6 * intensity),
        color.withOpacity(0.1 * intensity),
        color.withOpacity(0.05 * intensity),
        color.withOpacity(0),
      ],
      stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
    );

    // Gradient secondaire étendu
    final secondaryGradient = LinearGradient(
      begin: Alignment(combinedPosition * 0.8 - 1.0, -0.5),
      end: Alignment(combinedPosition * 0.8, 0.5),
      colors: [
        Colors.white.withOpacity(0),
        Colors.white.withOpacity(0.1 * intensity),
        Colors.white.withOpacity(0.2 * intensity),
        Colors.white.withOpacity(0),
      ],
      stops: const [0.0, 0.3, 0.5, 1.0],
    );

    // Translation du canvas pour commencer avant la carte
    canvas.save();
    canvas.translate(offset, 0);

    final mainPaint = Paint()
      ..shader = mainGradient.createShader(Rect.fromLTWH(0, 0, extendedWidth, size.height))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + intensity * 2);

    final secondaryPaint = Paint()
      ..shader = secondaryGradient.createShader(Rect.fromLTWH(0, 0, extendedWidth, size.height))
      ..style = PaintingStyle.fill;

    // Dessin sur la zone étendue
    canvas.drawRect(Rect.fromLTWH(0, 0, extendedWidth, size.height), mainPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, extendedWidth, size.height), secondaryPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(ImprovedShinePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class EnhancedStarFieldPainter extends CustomPainter {
  final List<EnhancedParticle> particles;
  final double animation;
  final double rotationValue;
  final double pulseValue;
   final Color color;

  EnhancedStarFieldPainter({
    required this.particles,
    required this.animation,
    required this.rotationValue,
    required this.pulseValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(vector.radians(rotationValue * 180));

    for (var particle in particles) {
      final angle = particle.angle + (animation * particle.speed * 360);
      final radius = particle.radius * (1 + pulseValue * particle.pulsation * 0.2);
      
      final x = math.cos(vector.radians(angle)) * radius;
      final y = math.sin(vector.radians(angle)) * radius;
      
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity * (0.7 + pulseValue * 0.3))
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      final particleSize = particle.size * (1 + pulseValue * 0.2);
      _drawEnhancedStar(canvas, x, y, particleSize, paint, particle.rotationSpeed * animation * 360);
    }
  }

  void _drawEnhancedStar(Canvas canvas, double x, double y, double size, Paint paint, double rotation) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(vector.radians(rotation));

    final path = Path();
    const points = 5;
    final innerRadius = size * 0.4;
    final outerRadius = size;

    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = vector.radians(i * 360 / (points * 2));
      final point = Offset(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
      );
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(EnhancedStarFieldPainter oldDelegate) {
    return oldDelegate.animation != animation || 
           oldDelegate.rotationValue != rotationValue ||
           oldDelegate.pulseValue != pulseValue;
  }
}

class EnhancedShinePainter extends CustomPainter {
  final double animation;
  final Color color;

  EnhancedShinePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Effet holographique principal
    final mainGradient = LinearGradient(
      begin: Alignment(animation * 3 - 1.5, -0.5),
      end: Alignment(animation * 3, 0.5),
      colors: [
        color.withOpacity(0),
        color.withOpacity(0.1),
        color.withOpacity(0.3),
        Colors.white.withOpacity(0.6),
        color.withOpacity(0.3),
        color.withOpacity(0.1),
        color.withOpacity(0),
      ],
      stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
    );

    // Effet de brillance secondaire
    final secondaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.1 * (1 - animation)),
        Colors.white.withOpacity(0.3 * animation),
        Colors.white.withOpacity(0.1 * (1 - animation)),
      ],
    );

    final mainPaint = Paint()
      ..shader = mainGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final secondaryPaint = Paint()
      ..shader = secondaryGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Dessin des effets
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), mainPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), secondaryPaint);
  }

  @override
  bool shouldRepaint(EnhancedShinePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
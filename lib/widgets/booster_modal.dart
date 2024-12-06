import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateEnhancedParticles();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

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
    Future.delayed(Duration(milliseconds: _random.nextInt(1000) + 500), () {
      if (mounted) {
        _shineController.forward(from: 0).then((_) {
          if (mounted) _startShineAnimation();
        });
      }
    });
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
    onTap: () {
      _scaleController.reverse().then((_) => widget.onClose());
    },
    child: Container(
      color: theme.background.withOpacity(0.87),
      child: ScaleTransition(
        scale: _scaleController,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
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
              
 Container(
  width: 250,
  height: 350,
  child: Transform(
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateY(0.1) // Légère rotation Y
      ..rotateX(-0.05), // Légère rotation X
    alignment: FractionalOffset.center,
    child: Container(
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
                      color: theme.primary.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: theme.accent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _shineController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(250, 350),
                          painter: EnhancedShinePainter(
                            animation: _shineController.value,
                            color: theme.text,
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.text.withOpacity(0.1),
                            theme.text.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: // AnimatedBuilder principal qui gère l'effet 3D de la carte
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(math.sin(_pulseController.value * math.pi) * 0.1)
                                ..rotateX(math.cos(_pulseController.value * math.pi) * 0.05),
                              alignment: FractionalOffset.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
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
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,  // Pour centrer le texte
                                    children: [
                                      // Conteneur pour les ombres
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
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
                                        ),
                                      ),
                                      // Bordure de la carte
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: theme.text.withOpacity(0.2),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      // Texte du titre
                                      Text(
                                        widget.cardData.title,
                                        style: TextStyle(
                                          color: theme.text,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: theme.primary.withOpacity(0.5 + _pulseController.value * 0.3),
                                              blurRadius: 10 + _pulseController.value * 5,
                                              offset: const Offset(0, 0),
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
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                    ),
                  ],
                ),
              ),
          ))],
          ),
        ),
      ),
    ),
  );
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
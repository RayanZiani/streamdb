import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/theme_constants.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController; 
  late final List<AnimationController> _starControllers;
  final List<Star> _stars = List.generate(20, (index) => Star());

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _starControllers = List.generate(
      _stars.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1000 + math.Random().nextInt(1000)),
        vsync: this,
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(
              Duration(milliseconds: math.Random().nextInt(2000)),
              () {
                if (mounted) {
                  _starControllers[index].reverse();
                }
              },
            );
          } else if (status == AnimationStatus.dismissed) {
            Future.delayed(
              Duration(milliseconds: math.Random().nextInt(1000)),
              () {
                if (mounted) {
                  _starControllers[index].forward();
                }
              },
            );
          }
        })..forward(),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    for (var controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.dark.headerGradientStart,
              AppColors.dark.headerGradientMiddle,
              AppColors.dark.headerGradientEnd,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Étoiles animées
            ...List.generate(_stars.length, (index) {
              return Positioned(
                left: _stars[index].initialPosition.dx % size.width,
                top: _stars[index].initialPosition.dy % size.height,
                child: FadeTransition(
                  opacity: _starControllers[index],
                  child: _buildStar(_stars[index].size),
                ),
              );
            }),
            
            // Contenu central
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animé
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _logoController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.dark.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dark.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.movie,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < "StreamDB".length; i++)
                            AnimatedBuilder(
                              animation: _textController,
                              builder: (context, child) {
                                final sinValue = math.sin(
                                  (_textController.value * 2 * math.pi) + (i * 0.8)
                                );
                                return Transform.translate(
                                  offset: Offset(0, sinValue * 10),
                                  child: Text(
                                    "StreamDB"[i],
                                    style: TextStyle(
                                      fontSize: 32 + (sinValue * 2),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.8 + (sinValue * 0.2)),
                                      shadows: [
                                        Shadow(
                                          color: AppColors.dark.primary.withOpacity(0.5),
                                          blurRadius: 12 + (sinValue * 4),
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.6 + (math.sin(_textController.value * math.pi) * 0.4),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColors.dark.accent,
                                  AppColors.dark.primary,
                                  AppColors.dark.secondary,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Chargement en cours...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(double size) {
    return Icon(
      Icons.star,
      size: size,
      color: AppColors.dark.accent.withOpacity(0.6),
    );
  }
}

class Star {
  final double size = math.Random().nextDouble() * 15 + 5;
  final Offset initialPosition = Offset(
    math.Random().nextDouble() * 400,
    math.Random().nextDouble() * 800,
  );
  
  Offset getPosition(double time) {
    final movement = math.sin(time * 2 * math.pi) * 20;
    return Offset(
      initialPosition.dx + movement,
      initialPosition.dy + movement,
    );
  }
}
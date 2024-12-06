import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../providers/theme_providers.dart';
import '../constants/theme_constants.dart';
import 'animated_theme_switch.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 
              MediaQuery.of(context).padding.top + 10,
              20, 
              15),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.1, 0.4, 0.7, 0.9],
              colors: [
                colors.headerGradientStart.withOpacity(0.95),
                colors.headerGradientMiddle.withOpacity(0.85),
                colors.headerGradientEnd.withOpacity(0.9),
                colors.headerGradientEnd.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(45),
              bottomRight: Radius.circular(45),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.headerGradientEnd.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.headerGradientStart.withOpacity(0.05),
                    colors.headerGradientEnd.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(45),
                  bottomRight: Radius.circular(45),
                ),
              ),
              child: Stack(
                fit: StackFit.loose,
                children: [
                  // Pattern en arrière-plan
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BackgroundPatternPainter(
                        color: colors.text.withOpacity(0.03),
                      ),
                    ),
                  ),
                  // Contenu principal
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Hero(
                                tag: 'header_title',
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: colors.text,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedThemeSwitch(
                              isDarkMode: themeProvider.isDarkMode,
                              onToggle: () => themeProvider.toggleTheme(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: colors.textSecondary.withOpacity(0.8),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textSecondary,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});
  
@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final spacing = 20; 
  for (int i = 0; i < size.width; i += spacing) { 
    for (int j = 0; j < size.height; j += spacing) { 
      canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 2, paint);
    }
  }
}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
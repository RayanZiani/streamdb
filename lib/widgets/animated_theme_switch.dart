import 'package:flutter/material.dart';

class AnimatedThemeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final Function() onToggle;

  const AnimatedThemeSwitch({
    Key? key,
    required this.isDarkMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 70,
        height: 35,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isDarkMode 
              ? Colors.purple.withOpacity(0.3) 
              : Colors.amber.withOpacity(0.3),
          border: Border.all(
            color: isDarkMode ? Colors.purple : Colors.amber,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: isDarkMode 
                  ? Alignment.centerRight 
                  : Alignment.centerLeft,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode 
                        ? [Colors.purple, Colors.deepPurple] 
                        : [Colors.amber, Colors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? Colors.purple : Colors.amber).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    key: ValueKey(isDarkMode),
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Étoiles animées en mode sombre
            if (isDarkMode) ...[
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: 10.0 * i,
                  top: 5.0 * (i % 2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (i * 100)),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.star,
                          size: 4,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      );
                    },
                  ),
                ),
            ],
            // Rayons de soleil animés en mode clair
            if (!isDarkMode) ...[
              for (var i = 0; i < 4; i++)
                Positioned(
                  right: 10.0 * i,
                  top: 5.0 * (i % 2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (i * 100)),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber.withOpacity(0.6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
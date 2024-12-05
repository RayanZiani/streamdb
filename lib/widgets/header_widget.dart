import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_providers.dart';
import '../constants/theme_constants.dart';
import 'animated_theme_switch.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.headerGradientStart,
            colors.headerGradientMiddle,
            colors.headerGradientEnd,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                  letterSpacing: 1.2,
                ),
              ),
              AnimatedThemeSwitch(
                isDarkMode: themeProvider.isDarkMode,
                onToggle: () => themeProvider.toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colors.text.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
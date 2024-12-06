import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_providers.dart';
import '../constants/theme_constants.dart';

class NavBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBarWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: colors.background.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: colors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: colors.primary,
              unselectedItemColor: colors.textSecondary,
              items: [
                _buildNavItem(
                  Icons.home_rounded, 'Accueil', 0, colors.primary),
                _buildNavItem(
                  Icons.search_rounded, 'Recherche', 1, colors.primary),
                _buildNavItem(
                  Icons.star_rounded, 'Top', 2, colors.primary),
                _buildNavItem(
                  Icons.playlist_play_outlined, 'Playlist', 3, colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index, Color primaryColor) {
    final isSelected = currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../widgets/navbar_widget.dart';
import '../widgets/loading_screen.dart';
import '../providers/theme_providers.dart';
import '../constants/theme_constants.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const RankingScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simuler un temps de chargement pour l'animation
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.isDarkMode ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      body: _isLoading
        ? const LoadingScreen()
        : _screens[_currentIndex],
      bottomNavigationBar: _isLoading
        ? null
        : NavBarWidget(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
    );
  }
}
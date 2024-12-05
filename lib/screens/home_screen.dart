import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';
import '../widgets/header_widget.dart';
import '../providers/theme_providers.dart';
import '../constants/theme_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieService _movieService = MovieService();
  List<Movie> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final movies = await _movieService.getPopularMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans _loadMovies: $e');
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
      body: Column(
        children: [
          const HeaderWidget(
            title: 'Découvrez',
            subtitle: 'Les films populaires du moment',
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  )
                : _movies.isEmpty
                    ? Text(
                        'Aucun film trouvé',
                        style: TextStyle(color: colors.text),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            color: colors.cardBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                movie.title,
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                movie.releaseDate,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                ),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: movie.posterPath.isNotEmpty
                                    ? Image.network(
                                        MovieService.getImageUrl(movie.posterPath),
                                        width: 50,
                                        height: 75,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(
                                              Icons.error,
                                              color: colors.primary,
                                            ),
                                      )
                                    : Icon(
                                        Icons.movie,
                                        color: colors.primary,
                                      ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${movie.voteAverage.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'dart:math' as math;

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final MovieService _movieService = MovieService();
  int _selectedGenreId = 12;
  String _selectedGenreName = 'Aventure';
  List<Map<String, dynamic>>? _genres;
  Map<int, String> _movieGenres = {};

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    final genres = await _movieService.getGenres();
    setState(() {
      _genres = genres;
    });
  }

  Future<void> _loadMovieGenre(int movieId) async {
    if (!_movieGenres.containsKey(movieId)) {
      final genre = await _movieService.getMovieGenre(movieId);
      setState(() {
        _movieGenres[movieId] = genre;
      });
    }
  }

  Widget _buildTypeTag(bool isSeries) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSeries 
                    ? Colors.purple.withOpacity(0.8) 
                    : Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                isSeries ? 'SÉRIE' : 'FILM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenreSelector() {
    if (_genres == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedGenreId,
          icon: Transform.rotate(
            angle: -math.pi / 2,
            child: const Icon(Icons.chevron_left),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          items: _genres!.map((genre) {
            return DropdownMenuItem(
              value: genre['id'] as int,
              child: Text(
                genre['name'] as String,
                style: TextStyle(
                  color: _selectedGenreId == genre['id']
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedGenreId = newValue;
                _selectedGenreName = _genres!
                    .firstWhere((g) => g['id'] == newValue)['name'] as String;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, {bool showGenre = false, bool isSeries = false}) {
    if (showGenre) {
      _loadMovieGenre(movie.id);
    }

    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Hero(
                tag: 'movie-${movie.id}',
                child: Container(
                  height: 225,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(MovieService.getImageUrl(movie.posterPath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: _buildTypeTag(isSeries),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          if (showGenre)
            Text(
              _movieGenres[movie.id] ?? '...',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              movie.releaseDate.substring(0, 4),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovieRow(
    String title, 
    Future<List<Movie>> futureMovies, 
    {bool showGenre = false, bool isSeries = false}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (title.contains('genre'))
                Expanded(
                  child: _buildGenreSelector(),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: FutureBuilder<List<Movie>>(
            future: futureMovies,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildMovieCard(
                      snapshot.data![index],
                      showGenre: showGenre,
                      isSeries: isSeries,
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMovieRow(
              'Top Films 2024',
              _movieService.getTopMovies2024(),
              showGenre: true,
            ),
            _buildMovieRow(
              'Top Séries 2024',
              _movieService.getTopTVShows2024(),
              isSeries: true,
            ),
            _buildMovieRow(
              'Tendances',
              _movieService.getTrendingAll(),
            ),
            _buildMovieRow(
              'Films par genre',
              _movieService.getMoviesByGenre(_selectedGenreId),
            ),
            const SizedBox(height: 75)
          ],
        ),
      ),
    );
  }
}
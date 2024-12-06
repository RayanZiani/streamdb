import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'dart:math' as math;


class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> 
    with TickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  int _selectedGenreId = 12;
  List<Map<String, dynamic>>? _genres;
  Map<int, String> _movieGenres = {};
  
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _featuredContentAnimation;

  @override
  void initState() {
    super.initState();
    _loadGenres();
    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );

    _featuredContentAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
  }


   @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

 Future<void> _loadGenres() async {
    try {
      final genres = await _movieService.getGenres();
      if (mounted) {
        setState(() {
          _genres = genres;
        });
      }
    } catch (e) {
      debugPrint('Erreur de chargement des genres: $e');
    }
  }


  Future<void> _loadMovieGenre(int movieId) async {
    if (!_movieGenres.containsKey(movieId)) {
      final genre = await _movieService.getMovieGenre(movieId);
      setState(() {
        _movieGenres[movieId] = genre;
      });
    }
  }

  Widget _buildFeaturedContent(Movie movie) {
    return FadeTransition(
      opacity: _featuredContentAnimation,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              MovieService.getImageUrl(movie.backdropPath, backdrop: true),
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                   child: _buildFeaturedContentOverlay(movie),
                  )
                ],
              ),
            ),
          )
        );
  }

  Widget _buildTypeTag(bool isSeries) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSeries
            ? Colors.purple.withOpacity(0.9)
            : Theme.of(context).colorScheme.primary.withOpacity(0.9),
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
          letterSpacing: 1.5,
        ),
      ),
    );
  }


  Widget _buildFeaturedContentOverlay(Movie movie) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeTag(movie.mediaType == 'tv'),
            const SizedBox(height: 16),
            _buildMovieInfo(movie),
          ],
        ),
      ),
    );
  }

 Widget _buildMovieInfo(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP 1',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              movie.releaseDate.substring(0, 4),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreSelector() {
    if (_genres == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedGenreId,
          icon: Transform.rotate(
            angle: -math.pi / 2,
            child: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
            ),
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
                  fontWeight: _selectedGenreId == genre['id']
                      ? FontWeight.bold
                      : null,
                ),
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedGenreId = newValue;
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

  return FadeTransition(
    opacity: _fadeAnimation,
    child: Container(
      width: 170,
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
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
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
              Positioned(
                bottom: -20,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
    ),
  );
}

 Widget _buildMovieRow(
    String title,
    Future<List<Movie>> futureMovies, {
    bool showGenre = false,
    bool isSeries = false,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (title.contains('genre'))
                  Expanded(child: _buildGenreSelector()),
              ],
            ),
          ),
          SizedBox(
            height: 340,
            child: FutureBuilder<List<Movie>>(
              future: futureMovies,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      // Décalage progressif des animations pour chaque carte
                      final itemAnimation = CurvedAnimation(
                        parent: _mainController,
                        curve: Interval(
                          0.1 * (index / snapshot.data!.length),
                          0.6 + 0.1 * (index / snapshot.data!.length),
                          curve: Curves.easeOut,
                        ),
                      );
                      return FadeTransition(
                        opacity: itemAnimation,
                        child: _buildMovieCard(
                          snapshot.data![index],
                          showGenre: showGenre,
                          isSeries: isSeries,
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Optimisation du scroll
          if (scrollInfo is ScrollStartNotification) {
            // Pause des animations pendant le défilement
            _mainController.stop();
          } else if (scrollInfo is ScrollEndNotification) {
            // Reprise des animations après le défilement
            _mainController.forward();
          }
          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Movie>>(
                future: _movieService.getTopMovies2024(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return _buildFeaturedContent(snapshot.data!.first);
                  }
                  return const SizedBox(height: 500);
                },
              ),
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
                _movieService.getTrendingContent(),
              ),
              _buildMovieRow(
                'Contenu par genre',
                _movieService.getContentByGenre(_selectedGenreId),
              ),
              const SizedBox(height: 75),
            ],
          ),
        ),
      ),
    );
  }
}
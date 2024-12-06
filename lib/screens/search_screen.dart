import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../models/movie.dart';
import '../widgets/header_widget.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final MovieService _movieService = MovieService();
  Timer? _debounce;
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  bool _isValidSearch(String query) {
    return query.replaceAll(' ', '').length >= 2;
  }

 void _onSearchChanged(String query) {
  if (query.isEmpty) {
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _isLoading = false;
    });
    return;
  }
  
  setState(() => _hasSearched = true);
  
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () async {
    if (!_isValidSearch(query)) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _movieService.searchContent(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
        // Redémarrer l'animation lorsque de nouveaux résultats arrivent
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue lors de la recherche'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  });
}


  Widget _buildBadge({
    required String text,
    required Color color,
    IconData? icon,
    bool hasBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: hasBorder ? Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Movie movie, BuildContext context) {
    final isSeries = movie.mediaType == 'tv';
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color backgroundColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              SizedBox(
                width: 133,
                // ignore: unnecessary_null_comparison
                child: movie.posterPath != null
                    ? Image.network(
                        MovieService.getImageUrl(movie.posterPath),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: primaryColor,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: backgroundColor,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.movie,
                          size: 40,
                          color: secondaryTextColor,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildBadge(
                            text: isSeries ? 'SÉRIE' : 'FILM',
                            color: isSeries ? Colors.purple : primaryColor,
                            hasBorder: false,
                          ),
                          const Spacer(),
                          _buildBadge(
                            text: (movie.voteAverage).toStringAsFixed(1),
                            color: primaryColor,
                            icon: Icons.star_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        movie.title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (movie.releaseDate.isNotEmpty)
                        Text(
                          'Sortie le ${movie.releaseDate.substring(8, 10)}/'
                          '${movie.releaseDate.substring(5, 7)}/'
                          '${movie.releaseDate.substring(0, 4)}',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (movie.overview.isNotEmpty)
                        Expanded(
                          child: Text(
                            movie.overview,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color backgroundColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final Color hintColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Hero(
        tag: 'searchBar',
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Rechercher un film ou une série...',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.search, color: primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: primaryColor),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderWidget(
                    title: 'Recherchez',
                    subtitle: 'Votre série ou film préféré',
                  ),
                  _buildSearchBar(),
                ],
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!_hasSearched)
              SliverFillRemaining(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: primaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Commencez votre recherche',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Découvrez des films et séries passionnants',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.movie_filter_outlined,
                        size: 64,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun résultat trouvé',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essayez avec d\'autres mots-clés',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final movie = _searchResults[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  ((index + 1) * 0.1).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: child,
                          );
                        },
                        child: _buildContentCard(movie, context),
                      );
                    },
                    childCount: _searchResults.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String apiKey = 'f2903820f24998d80ac858927d4552ff';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final url = '$baseUrl/movie/popular?api_key=$apiKey&page=$page&language=fr-FR';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
        return movies;
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

   Future<List<Movie>> getTopMovies2024() async {
    final url = '$baseUrl/discover/movie?api_key=$apiKey'
        '&language=fr-FR'
        '&sort_by=vote_average.desc'
        '&primary_release_year=2024'
        '&vote_count.gte=100'
        '&include_adult=false'
        '&page=1';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .take(10)
            .toList();
        return movies;
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getTrendingMovies() async {
    final url = '$baseUrl/trending/movie/week?api_key=$apiKey&language=fr-FR';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .take(6)
            .toList();
        return movies;
      } else {
        throw Exception('Failed to load trending movies: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final url = '$baseUrl/discover/movie?api_key=$apiKey'
        '&language=fr-FR'
        '&sort_by=vote_average.desc'
        '&with_genres=$genreId'
        '&vote_count.gte=100'
        '&page=1';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .take(10)
            .toList();
        return movies;
      } else {
        throw Exception('Failed to load genre movies: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getTopTVShows2024() async {
    final url = '$baseUrl/discover/tv?api_key=$apiKey'
        '&language=fr-FR'
        '&sort_by=vote_average.desc'
        '&first_air_date_year=2024'
        '&vote_count.gte=50'
        '&include_adult=false'
        '&page=1';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final shows = (data['results'] as List)
            .map((show) => Movie.fromJson({
                  'id': show['id'],
                  'title': show['name'],
                  'poster_path': show['poster_path'],
                  'backdrop_path': show['backdrop_path'],
                  'overview': show['overview'],
                  'vote_average': show['vote_average'],
                  'release_date': show['first_air_date'],
                }))
            .take(10)
            .toList();
        return shows;
      } else {
        throw Exception('Failed to load TV shows: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

    Future<List<Movie>> getContentByGenre(int genreId) async {
    final movieUrl = '$baseUrl/discover/movie?api_key=$apiKey'
        '&language=fr-FR'
        '&sort_by=vote_average.desc'
        '&with_genres=$genreId'
        '&vote_count.gte=100'
        '&page=1';
        
    final tvUrl = '$baseUrl/discover/tv?api_key=$apiKey'
        '&language=fr-FR'
        '&sort_by=vote_average.desc'
        '&with_genres=$genreId'
        '&vote_count.gte=50'
        '&page=1';
    
    try {
      final movieResponse = await http.get(Uri.parse(movieUrl));
      final tvResponse = await http.get(Uri.parse(tvUrl));
      
      if (movieResponse.statusCode == 200 && tvResponse.statusCode == 200) {
        final movieData = json.decode(movieResponse.body);
        final tvData = json.decode(tvResponse.body);
        
        final movies = (movieData['results'] as List).map((movie) => Movie.fromJson(movie));
        
        final shows = (tvData['results'] as List).map((show) => Movie.fromJson({
          'id': show['id'],
          'title': show['name'],
          'poster_path': show['poster_path'],
          'backdrop_path': show['backdrop_path'],
          'overview': show['overview'],
          'vote_average': show['vote_average'],
          'release_date': show['first_air_date'],
          'media_type': 'tv'
        }));

        final allContent = [...movies, ...shows]
          ..sort((a, b) => (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0));
        
        return allContent.take(10).toList();
      } else {
        throw Exception('Failed to load content: ${movieResponse.statusCode}/${tvResponse.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getTrendingContent() async {
    final url = '$baseUrl/trending/all/week?api_key=$apiKey&language=fr-FR';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trending = (data['results'] as List)
            .map((item) => Movie.fromJson({
                  'id': item['id'],
                  'title': item['title'] ?? item['name'],
                  'poster_path': item['poster_path'],
                  'backdrop_path': item['backdrop_path'],
                  'overview': item['overview'],
                  'vote_average': item['vote_average'],
                  'release_date': item['release_date'] ?? item['first_air_date'],
                  'media_type': item['media_type']
                }))
            .take(6)
            .toList();
        return trending;
      } else {
        throw Exception('Failed to load trending content: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getMovieGenre(int movieId) async {
    final url = '$baseUrl/movie/$movieId?api_key=$apiKey&language=fr-FR';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = data['genres'] as List;
        if (genres.isNotEmpty) {
          return genres.first['name'];
        }
        return '';
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> getGenres() async {
    final url = '$baseUrl/genre/movie/list?api_key=$apiKey&language=fr-FR';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['genres']);
      } else {
        throw Exception('Failed to load genres: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static String getImageUrl(String path, {bool backdrop = false}) {
    String size = backdrop ? 'w1280' : 'w500';
    return '$imageBaseUrl/$size$path';
  }
}
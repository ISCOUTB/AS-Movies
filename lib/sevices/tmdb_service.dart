import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBService {
  final String _baseUrl = "https://api.themoviedb.org/3";
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;

  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final url = Uri.parse("$_baseUrl/movie/popular?api_key=$_apiKey&language=es-ES");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception("Failed to load popular movies");
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final url = Uri.parse("$_baseUrl/movie/$movieId?api_key=$_apiKey&language=es-ES&append_to_response=credits");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al obtener detalles de la película");
    }
  }

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final url = Uri.parse("$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=es-ES");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception("Error al buscar películas");
    }
  }

  Future<List<Map<String, dynamic>>> discoverMovies({int page = 1}) async {
    final url = Uri.parse("$_baseUrl/discover/movie?api_key=$_apiKey&language=es-ES&page=$page");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception("Error al descubrir películas");
    }
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/movie.dart';
import 'package:animations/animations.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TMDBService _tmdbService = TMDBService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  void _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _tmdbService.searchMovies(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error al buscar películas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscador de Películas"),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: _searchMovies,
              decoration: InputDecoration(
                hintText: "Buscar películas...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(child: Text("No hay resultados"))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return Scrollbar(
                            thumbVisibility: true,
                            child: GridView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: _searchResults.length,
                              physics: AlwaysScrollableScrollPhysics(),
                              shrinkWrap: false,
                              itemBuilder: (context, index) {
                                final movieMap = _searchResults[index];
                                final movie = Movie.fromJson(movieMap);
                                final imageUrl = movie.posterPath != null
                                    ? "https://image.tmdb.org/t/p/w500${movie.posterPath}"
                                    : '';
                                return AnimatedSlide(
                                  offset: Offset(0, 0.2),
                                  duration: Duration(milliseconds: 300 + index * 60),
                                  curve: Curves.easeOut,
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: Duration(milliseconds: 300 + index * 60),
                                    child: OpenContainer(
                                      closedElevation: 6,
                                      openElevation: 10,
                                      closedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      openShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      transitionDuration: Duration(milliseconds: 500),
                                      closedBuilder: (context, action) => GestureDetector(
                                        onTap: action,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: imageUrl.isNotEmpty
                                              ? Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  alignment: Alignment.topCenter,
                                                  errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.white)),
                                                )
                                              : Container(
                                                  color: Colors.grey[800],
                                                  child: Icon(Icons.movie, color: Colors.white, size: 48),
                                                ),
                                        ),
                                      ),
                                      openBuilder: (context, action) => MovieDetailsExpanded(
                                        movie: movie,
                                        imageUrl: imageUrl,
                                        onClose: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

class TMDBService {
  final String _baseUrl = "https://api.themoviedb.org/3";
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;

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
}

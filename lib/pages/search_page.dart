import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

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

  void _showMovieDetails(Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(movie['title']),
          content: SingleChildScrollView(
            child: Column(
              children: [
                movie['poster_path'] != null
                    ? Image.network(
                        "https://image.tmdb.org/t/p/w500${movie['poster_path']}",
                        height: 200,
                      )
                    : SizedBox(),
                SizedBox(height: 10),
                Text(movie['overview'] ?? "Sin descripción"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
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
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final movie = _searchResults[index];
                          final imageUrl =
                              "https://image.tmdb.org/t/p/w500${movie['poster_path']}";

                          return ListTile(
                            leading: movie['poster_path'] != null
                                ? Image.network(imageUrl, width: 50)
                                : Icon(Icons.movie),
                            title: Text(movie['title']),
                            subtitle: Text(
                              movie['overview'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _showMovieDetails(movie),
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
    final url = Uri.parse("$_baseUrl/search/movie?api_key=$_apiKey&query=$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception("Error al buscar películas");
    }
  }
}

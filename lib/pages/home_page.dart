import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TMDBService _tmdbService = TMDBService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPopularMovies();
  }

  Future<void> _fetchPopularMovies() async {
    try {
      final movies = await _tmdbService.getPopularMovies();
      print("Películas obtenidas: ${movies.length}"); // Verifica los datos
      print("Primera película: ${movies[0]}"); // Verifica el contenido de la primera película
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching movies: $e");
    }
  }

  void _showMovieDetails(Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(movie['title']),
          content: SingleChildScrollView(
            child: Text(movie['overview']),
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
        automaticallyImplyLeading: false, // Elimina el ícono de retroceso (si lo hay)
      ),
      body: Container(
        color: const Color.fromARGB(255, 2, 8, 29), // Fondo azul marino
        padding: EdgeInsets.only(top: 10), // Espacio entre la barra de navegación y el contenido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título "Películas Populares"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Películas Populares",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16), // Espacio entre el título y la cuadrícula
            // Cuadrícula de películas
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8), // Margen horizontal
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // Cuatro columnas
                        crossAxisSpacing: 8, // Espacio entre columnas
                        mainAxisSpacing: 8, // Espacio entre filas
                        childAspectRatio: 0.6, // Relación de aspecto (ancho/alto)
                      ),
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        final imageUrl = "https://image.tmdb.org/t/p/w500${movie['poster_path']}";
                        return GestureDetector(
                          onTap: () => _showMovieDetails(movie), // Mostrar detalles al hacer clic
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    movie['title'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Máximo de 2 líneas para el título
                                    overflow: TextOverflow.ellipsis, // Puntos suspensivos si el texto es muy largo
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TMDBService {
  final String _baseUrl = "https://api.themoviedb.org/3";
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;

  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final url = Uri.parse("$_baseUrl/movie/popular?api_key=$_apiKey");
    print("URL de la API: $url"); // Verifica la URL
    final response = await http.get(url);
    print("Respuesta de la API: ${response.statusCode}"); // Verifica el código de estado
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Datos de la API: $data"); // Verifica los datos
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception("Failed to load popular movies");
    }
  }
}
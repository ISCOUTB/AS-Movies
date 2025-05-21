import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:percent_indicator/percent_indicator.dart';

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

  Color _getScoreColor(num score) {
    if (score >= 7.0) {
      return Colors.greenAccent.shade400;
    } else if (score >= 5.0) {
      return Colors.orangeAccent.shade200;
    } else {
      return Colors.redAccent.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Películas Populares",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.7),
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con la imagen de butacas (igual que login)
          Image.asset(
            'assets/images/login.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcula el ancho ideal para 5 tarjetas con separación (más pequeñas)
                final cardSpacing = 16.0;
                final cardsVisible = 5;
                final cardWidth = (constraints.maxWidth * 0.70 - (cardSpacing * (cardsVisible - 1))) / cardsVisible;
                final cardHeight = cardWidth * 1.2; // Proporción más ancha y menos alta
                return _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : CarouselSlider.builder(
                        itemCount: _movies.length,
                        itemBuilder: (context, index, realIdx) {
                          final movie = _movies[index];
                          final imageUrl = "https://image.tmdb.org/t/p/w500${movie['poster_path']}";
                          return GestureDetector(
                            onTap: () => _showMovieDetails(movie),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4), // Espacio entre tarjetas
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.zero, // Elimina cualquier margen extra
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return Center(child: CircularProgressIndicator());
                                        },
                                        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.white)),
                                      ),
                                    ),
                                    // Puntuación de usuarios en la esquina superior izquierda
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: CircularPercentIndicator(
                                        radius: 22,
                                        lineWidth: 4,
                                        percent: (movie['vote_average'] ?? 0) / 10.0,
                                        animation: true,
                                        animationDuration: 600,
                                        backgroundColor: Colors.black,
                                        progressColor: _getScoreColor(movie['vote_average'] ?? 0),
                                        circularStrokeCap: CircularStrokeCap.round,
                                        center: Text(
                                          '${(movie['vote_average'] * 10).toInt()}%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4,
                                                color: Colors.black,
                                                offset: Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: cardHeight + 48,
                          enlargeCenterPage: false,
                          viewportFraction: cardWidth / constraints.maxWidth,
                          enableInfiniteScroll: true,
                          initialPage: 2,
                          pageSnapping: true,
                          padEnds: false,
                          disableCenter: true,
                          scrollPhysics: BouncingScrollPhysics(),
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

  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final url = Uri.parse("$_baseUrl/movie/popular?api_key=$_apiKey&language=es-ES");
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
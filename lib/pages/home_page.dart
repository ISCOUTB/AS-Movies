import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:animations/animations.dart';

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
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4), // Espacio entre tarjetas
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
                                onTap: action, // Ejecuta la animación de expansión
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
                              openBuilder: (context, action) => FutureBuilder<Map<String, dynamic>>(
                                future: _tmdbService.getMovieDetails(movie['id']),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  return _MovieDetailsExpanded(
                                    movie: snapshot.data!,
                                    imageUrl: imageUrl,
                                    onClose: () => Navigator.of(context).pop(),
                                  );
                                },
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

class _MovieDetailsExpanded extends StatelessWidget {
  final Map<String, dynamic> movie;
  final String imageUrl;
  final VoidCallback onClose;

  const _MovieDetailsExpanded({required this.movie, required this.imageUrl, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final genres = (movie['genres'] as List?)?.map((g) => g['name']).join(', ') ?? '';
    final directors = (movie['credits']?['crew'] as List?)?.where((c) => c['job'] == 'Director').map((c) => c['name']).join(', ') ?? '';
    return Material(
      color: Colors.black.withOpacity(0.95),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 180,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 180,
                  height: 260,
                  color: Colors.grey[800],
                  child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                ),
              ),
            ),
            SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    movie['title'] ?? '',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 6),
                      Text(
                        (movie['vote_average']?.toStringAsFixed(1) ?? '0'),
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Fecha de estreno: ${movie['release_date'] ?? ''}',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Directores: $directors',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Categorías: $genres',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  Text(
                    movie['overview'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton.icon(
                      onPressed: onClose,
                      icon: Icon(Icons.close),
                      label: Text('Cerrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
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
      throw Exception("Failed to load movie details");
    }
  }
}
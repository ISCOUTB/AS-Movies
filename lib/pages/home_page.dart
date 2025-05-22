import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/movie.dart';

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
          style: GoogleFonts.poppins(
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
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
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
          // Rectángulo de bienvenida
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 150.0),
              child: FractionallySizedBox(
                widthFactor: 1.0, // Ocupa todo el ancho de la pantalla
                child: Container(
                  height: 240,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: const Color(0xFF232526), // Negro metálico elegante
                    borderRadius: BorderRadius.zero,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF232526), // Gris oscuro metálico
                        Color(0xFF414345), // Gris metálico más claro
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Te damos la bienvenida.',
                          style: GoogleFonts.poppins(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Millones de películas, series y gente por descubrir. Explora ya.',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Carousel y contenido principal
          Padding(
            padding: const EdgeInsets.only(top: 250.0),
            child: Center(
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
                            final movieMap = _movies[index];
                            final movie = Movie.fromJson(movieMap);
                            final imageUrl = movie.posterPath != null
                                ? "https://image.tmdb.org/t/p/w500${movie.posterPath}"
                                : "https://image.tmdb.org/t/p/w500";
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                          percent: (movie.voteAverage) / 10.0,
                                          animation: true,
                                          animationDuration: 600,
                                          backgroundColor: Colors.black,
                                          progressColor: _getScoreColor(movie.voteAverage),
                                          circularStrokeCap: CircularStrokeCap.round,
                                          center: Text(
                                            '${(movie.voteAverage * 10).toInt()}%',
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
                                  future: _tmdbService.getMovieDetails(movie.id),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    final detailedMovie = Movie.fromJson(snapshot.data!);
                                    final detailedImageUrl = detailedMovie.posterPath != null
                                        ? "https://image.tmdb.org/t/p/w500${detailedMovie.posterPath}"
                                        : "https://image.tmdb.org/t/p/w500";
                                    return MovieDetailsExpanded(
                                      movie: detailedMovie,
                                      imageUrl: detailedImageUrl,
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
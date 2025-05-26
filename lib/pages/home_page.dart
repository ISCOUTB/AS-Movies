import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/movie.dart';
import '../sevices/tmdb_service.dart';

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
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: CustomPaint(
                                                painter: _ScoreCirclePainter(
                                                  percent: movie.voteAverage / 10.0,
                                                  color: movie.voteAverage >= 7.0
                                                      ? Colors.greenAccent.shade400
                                                      : movie.voteAverage >= 5.0
                                                          ? Colors.orangeAccent.shade200
                                                          : Colors.redAccent.shade200,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.4),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${(movie.voteAverage * 10).toInt()}%',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius: 2,
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

// Custom painter para la barra de progreso
class _ScoreCirclePainter extends CustomPainter {
  final double percent;
  final Color color;
  _ScoreCirclePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final Paint fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;
    canvas.drawCircle(center, radius, bgPaint);
    final sweepAngle = 2 * 3.141592653589793 * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
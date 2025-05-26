import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/movie.dart';
import '../sevices/tmdb_service.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TypeAheadField<Map<String, dynamic>>(
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) return [];
                      try {
                        return await _tmdbService.searchMovies(pattern);
                      } catch (_) {
                        return [];
                      }
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: suggestion['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w92${suggestion['poster_path']}',
                                width: 32,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.movie),
                        title: Text(suggestion['title'] ?? ''),
                        subtitle: suggestion['release_date'] != null
                            ? Text(suggestion['release_date'])
                            : null,
                      );
                    },
                    onSelected: (suggestion) {
                      setState(() {
                        _searchController.text = suggestion['title'] ?? '';
                      });
                      _searchMovies(suggestion['title'] ?? '');
                    },
                    emptyBuilder: (context) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No hay sugerencias'),
                    ),
                    controller: _searchController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: "Buscar películas...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (value) {
                          _searchMovies(value); // Buscar al presionar enter
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                          ? Center(child: Text("No hay resultados"))
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final movieMap = _searchResults[index];
                                  final movie = Movie.fromJson(movieMap);
                                  final imageUrl = movie.posterPath != null
                                      ? "https://image.tmdb.org/t/p/w500${movie.posterPath}"
                                      : "https://image.tmdb.org/t/p/w500";
                                  return OpenContainer(
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
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                              errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.white)),
                                            ),
                                          ),
                                          // Puntuación circular como en categories_page.dart
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
                                  );
                                },
                              ),
                            ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painter para el círculo de puntuación
class _ScoreCirclePainter extends CustomPainter {
  final double percent;
  final Color color;
  _ScoreCirclePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint base = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final Paint arc = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    canvas.drawCircle(center, radius, base);
    final sweep = 2 * 3.141592653589793 * percent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

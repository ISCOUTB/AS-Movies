import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../sevices/tmdb_service.dart';

class DiscoverPage extends StatefulWidget {
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with SingleTickerProviderStateMixin {
  List<Movie> movies = [];
  List<Movie> likedMovies = [];
  int swipedCount = 0;
  final int minSwipes = 10;
  bool showRecommendations = false;
  int currentIndex = 0;
  bool isLoading = true;
  bool isAnimating = false;
  double cardOpacity = 1.0;

  // Variables para animación de desplazamiento
  double cardOffsetX = 0.0;
  double cardRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  // Cambia este método para traer muchas más películas (paginando)
  Future<void> _fetchMovies() async {
    setState(() { isLoading = true; });
    try {
      List<Movie> allMovies = [];
      int page = 1;
      int maxPages = 5; // Puedes ajustar este número para traer más páginas
      while (page <= maxPages) {
        final results = await TMDBService().discoverMovies(page: page);
        allMovies.addAll(results.map((m) => Movie.fromJson(m)));
        page++;
      }
      setState(() {
        movies = allMovies;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  Future<void> onSwipe(bool liked) async {
    if (isAnimating || currentIndex >= movies.length) return;
    setState(() { isAnimating = true; cardOpacity = 1.0; });
    if (liked) likedMovies.add(movies[currentIndex]);
    swipedCount++;
    // Animación de desplazamiento
    double endOffset = liked ? 500.0 : -500.0;
    double endRotation = liked ? 0.2 : -0.2;
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 10));
      setState(() {
        cardOffsetX = endOffset * (i + 1) / 10;
        cardRotation = endRotation * (i + 1) / 10;
      });
    }
    await Future.delayed(Duration(milliseconds: 100));
    setState(() { cardOpacity = 0.0; });
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      isAnimating = false;
      cardOpacity = 1.0;
      cardOffsetX = 0.0;
      cardRotation = 0.0;
      if (swipedCount >= minSwipes) {
        showRecommendations = true;
      } else {
        currentIndex++;
      }
    });
  }

  List<Movie> getRecommendations() {
    return movies.where((m) => !likedMovies.contains(m)).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Descubrir",
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
        automaticallyImplyLeading: false,
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : showRecommendations
                  ? _buildRecommendations()
                  : _buildTinderCard(),
        ],
      ),
    );
  }

  Widget _buildTinderCard() {
    if (movies.isEmpty || currentIndex >= movies.length) {
      return Center(child: Text('No se encontraron películas', style: TextStyle(color: Colors.white)));
    }
    final movie = movies[currentIndex];
    final imageUrl = movie.posterPath != null
        ? "https://image.tmdb.org/t/p/w500${movie.posterPath}"
        : "https://image.tmdb.org/t/p/w500";
    // Proporción 2:3, aún más pequeño
    final double cardWidth = MediaQuery.of(context).size.width * 0.22;
    final double cardHeight = cardWidth * 1.5;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: cardOpacity,
            duration: Duration(milliseconds: 250),
            child: Transform.translate(
              offset: Offset(cardOffsetX, 0),
              child: Transform.rotate(
                angle: cardRotation,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[800],
                            child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                            ),
                          ),
                          padding: EdgeInsets.all(cardWidth * 0.06),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: cardWidth * 0.07, // Más pequeño
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: cardWidth * 0.02),
                              Text(
                                movie.overview,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: cardWidth * 0.04, // Más pequeño
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'dislike',
                mini: true,
                backgroundColor: Colors.redAccent,
                onPressed: isAnimating ? null : () => onSwipe(false),
                child: Icon(Icons.thumb_down, color: Colors.white, size: 22),
              ),
              SizedBox(width: 32),
              FloatingActionButton(
                heroTag: 'like',
                mini: true,
                backgroundColor: Colors.green,
                onPressed: isAnimating ? null : () => onSwipe(true),
                child: Icon(Icons.thumb_up, color: Colors.white, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recs = getRecommendations();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "¡Te recomendamos estas películas!",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.68,
              ),
              itemCount: recs.length,
              itemBuilder: (context, index) {
                final movie = recs[index];
                final imageUrl = movie.posterPath != null
                    ? "https://image.tmdb.org/t/p/w500${movie.posterPath}"
                    : "https://image.tmdb.org/t/p/w500";
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              movie.overview,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                swipedCount = 0;
                likedMovies.clear();
                showRecommendations = false;
                currentIndex = 0;
              });
            },
            child: Text('Volver a descubrir'),
          ),
        ],
      ),
    );
  }
}
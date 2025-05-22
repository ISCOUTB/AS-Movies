import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';
import 'package:animations/animations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<Map<String, dynamic>> categories = [
    {'id': 28, 'name': 'Acción', 'icon': Icons.local_fire_department},
    {'id': 12, 'name': 'Aventura', 'icon': Icons.explore},
    {'id': 16, 'name': 'Animación', 'icon': Icons.animation},
    {'id': 35, 'name': 'Comedia', 'icon': Icons.emoji_emotions},
    {'id': 80, 'name': 'Crimen', 'icon': Icons.gavel},
    {'id': 99, 'name': 'Documental', 'icon': Icons.movie},
    {'id': 18, 'name': 'Drama', 'icon': Icons.theater_comedy},
    {'id': 10751, 'name': 'Familia', 'icon': Icons.family_restroom},
    {'id': 14, 'name': 'Fantasía', 'icon': Icons.auto_awesome},
    {'id': 36, 'name': 'Historia', 'icon': Icons.history_edu},
    {'id': 27, 'name': 'Terror', 'icon': Icons.dangerous},
    {'id': 10402, 'name': 'Música', 'icon': Icons.music_note},
    {'id': 9648, 'name': 'Misterio', 'icon': Icons.visibility},
    {'id': 10749, 'name': 'Romance', 'icon': Icons.favorite},
    {'id': 878, 'name': 'Ciencia ficción', 'icon': Icons.science},
    {'id': 10770, 'name': 'Película de TV', 'icon': Icons.tv},
    {'id': 53, 'name': 'Suspense', 'icon': Icons.hourglass_top},
    {'id': 10752, 'name': 'Bélica', 'icon': Icons.military_tech},
    {'id': 37, 'name': 'Western', 'icon': Icons.west},
  ];

  Map<String, dynamic>? _selectedCategory;
  int? _selectedIndex;
  bool _isCategoryTapped = false;

  void _onCategoryTap(int index) async {
    setState(() {
      _selectedCategory = categories[index];
      _selectedIndex = index;
      _isCategoryTapped = true;
    });
    await Future.delayed(Duration(milliseconds: 180));
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: CategoryMoviesPage(
            category: categories[index],
          ),
        ),
      ),
    );
    setState(() {
      _isCategoryTapped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // No AppBar aquí, la barra de navegación viene de MainScreen
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
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  SizedBox(height: 140), // Espacio para la barra de navegación superior
                  Expanded(
                    child: Center(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 2.8,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndex == index && _isCategoryTapped;
                          return AnimatedScale(
                            scale: isSelected ? 1.12 : 1.0,
                            duration: Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              child: InkWell(
                                onTap: () => _onCategoryTap(index),
                                borderRadius: BorderRadius.circular(15),
                                child: SizedBox(
                                  height: 56,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(categories[index]['icon'], color: Colors.black, size: 26),
                                      SizedBox(width: 10),
                                      Text(
                                        categories[index]['name'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Nueva página para mostrar películas de la categoría seleccionada
class CategoryMoviesPage extends StatefulWidget {
  final Map<String, dynamic> category;
  const CategoryMoviesPage({required this.category});

  @override
  State<CategoryMoviesPage> createState() => _CategoryMoviesPageState();
}

class _CategoryMoviesPageState extends State<CategoryMoviesPage> {
  List<Map<String, dynamic>> movies = [];
  bool isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies({bool loadMore = false}) async {
    final String apiKey = dotenv.env['TMDB_API_KEY']!;
    final int nextPage = loadMore ? _currentPage + 1 : 1;
    final String url =
        "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=${widget.category['id']}&language=es-ES&page=$nextPage";
    if (loadMore) setState(() => _isLoadingMore = true);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (loadMore) {
          movies.addAll(List<Map<String, dynamic>>.from(data['results']));
          _currentPage = nextPage;
        } else {
          movies = List<Map<String, dynamic>>.from(data['results']);
          _currentPage = 1;
        }
        _totalPages = data['total_pages'] ?? 1;
        isLoading = false;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.97),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(widget.category['icon'], color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(widget.category['name'], style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : movies.isEmpty
              ? Center(child: Text("No hay películas disponibles", style: TextStyle(color: Colors.white)))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final cardSpacing = 16.0;
                    final cardsVisible = 5;
                    final cardWidth = (constraints.maxWidth * 0.70 - (cardSpacing * (cardsVisible - 1))) / cardsVisible;
                    final cardHeight = cardWidth * 1.6;
                    return Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.70,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: cardSpacing,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: cardWidth / cardHeight,
                                ),
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                  final movieMap = movies[index];
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
                                              width: cardWidth,
                                              height: cardHeight,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                              errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.white)),
                                            ),
                                          ),
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
                                              progressColor: movie.voteAverage >= 7.0
                                                  ? Colors.greenAccent.shade400
                                                  : movie.voteAverage >= 5.0
                                                      ? Colors.orangeAccent.shade200
                                                      : Colors.redAccent.shade200,
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
                                    openBuilder: (context, action) => MovieDetailsExpanded(
                                      movie: movie,
                                      imageUrl: imageUrl,
                                      onClose: () => Navigator.of(context).pop(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_currentPage < _totalPages)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                                child: SizedBox(
                                  width: 220,
                                  height: 56,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: _isLoadingMore ? null : () => _fetchMovies(loadMore: true),
                                    child: _isLoadingMore
                                        ? SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Text('Mostrar más'),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';
import 'package:animations/animations.dart';

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

  // Estado para animación de selección
  int? _selectedIndex;
  bool _isCategoryTapped = false;

  void _onCategoryTap(int index) async {
    setState(() {
      _selectedCategory = categories[index];
      _selectedIndex = index;
      _isCategoryTapped = true;
    });
    await Future.delayed(Duration(milliseconds: 180));
    List<Map<String, dynamic>> movies = [];
    final String apiKey = dotenv.env['TMDB_API_KEY']!;
    final String url =
        "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=${_selectedCategory!['id']}&language=es-ES";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      movies = List<Map<String, dynamic>>.from(data['results']);
    } else {
      print("Error al obtener películas");
    }
    setState(() {
      _isCategoryTapped = false;
    });
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.98,
          minChildSize: 0.7,
          maxChildSize: 1.0,
          expand: false,
          builder: (context, scrollController) {
            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 1400, // Limita el ancho máximo para pantallas grandes
                  minWidth: 400,  // Ancho mínimo para pantallas pequeñas
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.97),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        Icon(_selectedCategory!['icon'], color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(_selectedCategory!['name'], style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: movies.isEmpty
                          ? Center(child: Text("No hay películas disponibles", style: TextStyle(color: Colors.white)))
                          : GridView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.7,
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.white)),
                                      ),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categorías"), backgroundColor: Colors.redAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: isSelected ? Colors.redAccent : Colors.black87,
                child: InkWell(
                  onTap: () => _onCategoryTap(index),
                  borderRadius: BorderRadius.circular(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categories[index]['icon'], color: Colors.white),
                      SizedBox(width: 10),
                      Text(categories[index]['name'], style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CategoriesPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'id': 28, 'name': 'Acción', 'icon': Icons.local_fire_department},
    {'id': 12, 'name': 'Aventura', 'icon': Icons.explore},
    {'id': 16, 'name': 'Animación', 'icon': Icons.animation},
    {'id': 878, 'name': 'Ciencia Ficción', 'icon': Icons.science},
    {'id': 35, 'name': 'Comedia', 'icon': Icons.emoji_emotions},
    {'id': 18, 'name': 'Drama', 'icon': Icons.theater_comedy},
    {'id': 14, 'name': 'Fantasía', 'icon': Icons.auto_awesome},
    {'id': 9648, 'name': 'Misterio', 'icon': Icons.visibility},
    {'id': 53, 'name': 'Suspenso', 'icon': Icons.hourglass_top},
    {'id': 27, 'name': 'Terror', 'icon': Icons.dangerous},
    {'id': 10749, 'name': 'Romance', 'icon': Icons.favorite},
    {'id': 99, 'name': 'Documentales', 'icon': Icons.movie},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categorías"), backgroundColor: Colors.redAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.black87,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoviesByCategoryPage(
                        categoryId: categories[index]['id'],
                        categoryName: categories[index]['name'],
                      ),
                    ),
                  );
                },
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
            );
          },
        ),
      ),
    );
  }
}

class MoviesByCategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  MoviesByCategoryPage({required this.categoryId, required this.categoryName});

  @override
  _MoviesByCategoryPageState createState() => _MoviesByCategoryPageState();
}

class _MoviesByCategoryPageState extends State<MoviesByCategoryPage> {
  List<Map<String, dynamic>> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMoviesByCategory();
  }

  Future<void> fetchMoviesByCategory() async {
    final String apiKey = dotenv.env['TMDB_API_KEY']!;
    final String url =
        "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=${widget.categoryId}&language=es-ES";
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        movies = List<Map<String, dynamic>>.from(data['results']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Error al obtener películas");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName), backgroundColor: Colors.redAccent),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : movies.isEmpty
              ? Center(child: Text("No hay películas disponibles"))
              : ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final imageUrl = "https://image.tmdb.org/t/p/w500${movie['poster_path']}";
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
                    );
                  },
                ),
    );
  }
}
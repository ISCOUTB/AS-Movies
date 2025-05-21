import 'package:flutter/material.dart';

class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final String overview;
  final String releaseDate;
  final List<String> genres;
  final List<String> directors;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    required this.overview,
    required this.releaseDate,
    required this.genres,
    required this.directors,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final genresList = (json['genres'] as List?)?.map((g) => g['name'] as String).toList() ?? [];
    final directorsList = (json['credits']?['crew'] as List?)
        ?.where((c) => c['job'] == 'Director')
        .map((c) => c['name'] as String)
        .toList() ?? [];
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      genres: genresList,
      directors: directorsList,
    );
  }
}

class MovieDetailsExpanded extends StatelessWidget {
  final Movie movie;
  final String imageUrl;
  final VoidCallback onClose;

  const MovieDetailsExpanded({required this.movie, required this.imageUrl, required this.onClose});

  @override
  Widget build(BuildContext context) {
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
                    movie.title,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 6),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Fecha de estreno: ${movie.releaseDate}',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Directores: ${movie.directors.join(', ')}',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Categorías: ${movie.genres.join(', ')}',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  Text(
                    movie.overview,
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

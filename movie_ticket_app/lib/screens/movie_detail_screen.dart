import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../utils/constants.dart';
import 'showtimes_screen.dart';


class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  
  Widget _buildCoverImage() {
    if (movie.posterUrl.isEmpty) {
      return Container(color: AppConstants.cardColor);
    }
    if (movie.isBase64Poster) {
      try {
        String cleanBase64 = movie.posterUrl.split(',').last;
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } catch (e) {
        return Container(color: AppConstants.cardColor);
      }
    }
    return Image.network(
      movie.posterUrl,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      
      body: Stack(
        children: [
          
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Stack(
                  children: [
                    SizedBox(
                      height: 400,
                      child: _buildCoverImage(),
                    ),
                    
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 200,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppConstants.backgroundColor,
                              AppConstants.backgroundColor.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text('${movie.duration} phút', style: TextStyle(color: Colors.grey[400])),
                          const SizedBox(width: 16),
                          Icon(Icons.movie_filter, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(movie.genre.join(', '), style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Nội dung phim',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.description,
                        style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                      ),
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ],
            ),
          ),

          
          Positioned(
            top: 40, 
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowtimesScreen(movie: movie),
                    ),
                  );
                },
                child: const Text(
                  'MUA VÉ NGAY',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
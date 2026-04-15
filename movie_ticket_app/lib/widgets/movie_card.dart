import 'dart:convert'; 
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../utils/constants.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    
    Widget buildPosterImage() {
      
      if (movie.posterUrl.isEmpty) {
        return Container(
          color: AppConstants.cardColor,
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
        );
      }

      
      if (movie.isBase64Poster) {
        try {
          
          String cleanBase64 = movie.posterUrl.split(',').last;
          
          return Image.memory(
            base64Decode(cleanBase64),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
          );
        } catch (e) {
          // Nếu giải mã lỗi
          return const Center(child: Icon(Icons.broken_image));
        }
      }

      
      return Image.network(
        movie.posterUrl,
        fit: BoxFit.cover,
        
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppConstants.cardColor,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: buildPosterImage(), 
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${movie.genre[0]} • ${movie.duration}m',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
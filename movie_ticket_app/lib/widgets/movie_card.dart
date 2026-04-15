import 'dart:convert'; // THÊM THƯ VIỆN NÀY
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../utils/constants.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // HÀM HỖ TRỢ HIỂN THỊ ẢNH THÔNG MINH
    Widget buildPosterImage() {
      // 1. Trường hợp không có poster
      if (movie.posterUrl.isEmpty) {
        return Container(
          color: AppConstants.cardColor,
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
        );
      }

      // 2. Trường hợp là dữ liệu Base64 (từ seeder)
      if (movie.isBase64Poster) {
        try {
          // Tách bỏ phần "data:image/jpeg;base64," để lấy mã sạch
          String cleanBase64 = movie.posterUrl.split(',').last;
          // Giải mã và hiển thị bằng Image.memory
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

      // 3. Trường hợp là link URL mạng (http/https - link thật)
      return Image.network(
        movie.posterUrl,
        fit: BoxFit.cover,
        // Nếu tải ảnh từ mạng lỗi
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
            // Poster Phim (Đã được bọc Clips)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: buildPosterImage(), // GỌI HÀM THÔNG MINH Ở ĐÂY
              ),
            ),
            const SizedBox(height: 8),
            // Tên Phim & Thể loại (giữ nguyên code cũ)
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'admin_movie_form_screen.dart';

class AdminMovieListScreen extends StatelessWidget {
  const AdminMovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Phim')),
     
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Phim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMovieFormScreen())),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Chừa chỗ cho Floating Button
            itemCount: provider.movies.length,
            itemBuilder: (context, index) {
              final movie = provider.movies[index];
              return Card(
                color: AppConstants.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: movie.posterUrl.startsWith('http') ? NetworkImage(movie.posterUrl) : null,
                    child: movie.posterUrl.startsWith('http') ? null : const Icon(Icons.movie),
                  ),
                  title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  subtitle: Text('${movie.duration} phút'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminMovieFormScreen(movie: movie))),
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, movie.id, movie.title),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá phim "$title" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = Provider.of<AuthProvider>(context, listen: false).token!;
              final success = await Provider.of<MovieProvider>(context, listen: false).deleteMovie(id, token);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá thành công!')));
              }
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
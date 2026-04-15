import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart'; 
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../utils/constants.dart';
import 'movie_detail_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<MovieProvider>(context, listen: false).fetchMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        
        title: Row(
          children: [
            const Icon(Icons.theaters, color: AppConstants.primaryColor, size: 30),
            const SizedBox(width: 8),
            const Text('CINEMAX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2, color: Colors.white)),
          ],
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) return const Center(child: CircularProgressIndicator());
          if (movieProvider.movies.isEmpty) return const Center(child: Text('Chưa có phim.'));

          
          final bannerMovies = movieProvider.movies.take(3).toList();
          final listMovies = movieProvider.movies;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                CarouselSlider(
                  options: CarouselOptions(
                    height: 500.0, 
                    autoPlay: true,
                    viewportFraction: 1.0, 
                  ),
                  items: bannerMovies.map((movie) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          
                          movie.isBase64Poster
                              ? Image.memory(base64Decode(movie.posterUrl.split(',').last), fit: BoxFit.cover)
                              : Image.network(movie.posterUrl, fit: BoxFit.cover),
                          
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                  AppConstants.backgroundColor,
                                ],
                              ),
                            ),
                          ),
                          
                          Positioned(
                            bottom: 30,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppConstants.primaryColor, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('ĐANG HOT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                                Text(movie.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(movie.genre.join(' • '), style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),

                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Phim đang chiếu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listMovies.length,
                          itemBuilder: (context, index) {
                            return MovieCard(
                              movie: listMovies[index],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: listMovies[index]))),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 80), 
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
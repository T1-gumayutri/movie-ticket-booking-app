import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import '../utils/constants.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> _movies = [];
  bool _isLoading = false;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;

  Future<void> fetchMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/movies'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _movies = data.map((json) => Movie.fromJson(json)).toList();
      }
    } catch (e) {
      print('Lỗi lấy phim: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> addMovie(Map<String, dynamic> movieData, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/movies'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(movieData),
      );
      if (response.statusCode == 201) {
        await fetchMovies(); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  
  Future<bool> updateMovie(String movieId, Map<String, dynamic> movieData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/movies/$movieId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(movieData),
      );
      if (response.statusCode == 200) {
        await fetchMovies();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

 
  Future<bool> deleteMovie(String movieId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/movies/$movieId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        await fetchMovies();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
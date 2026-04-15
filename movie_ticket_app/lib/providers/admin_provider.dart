import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AdminProvider with ChangeNotifier {
  List<dynamic> _users = [];
  bool _isLoading = false;

  List<dynamic> get users => _users;
  bool get isLoading => _isLoading;

  List<dynamic> _showtimes = [];
  List<dynamic> get showtimes => _showtimes;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;
  List<dynamic> _allBookings = [];
  List<dynamic> get allBookings => _allBookings;
  // Lấy danh sách User
  Future<void> fetchUsers(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _users = jsonDecode(response.body);
      }
    } catch (e) {
      print('Lỗi fetch users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa User
  Future<bool> deleteUser(String userId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _users.removeWhere((user) => user['_id'] == userId); // Xóa khỏi danh sách hiện tại
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  Future<bool> addShowtime(Map<String,dynamic>data, String token) async{
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/showtimes'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(data),
    );
    return response.statusCode ==201;
  }
  Future<void> fetchAllShowtimes(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/showtimes'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _showtimes = jsonDecode(response.body);
      }
    } catch (e) {
      print('Lỗi fetch showtimes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Hàm Xóa suất chiếu
  Future<bool> deleteShowtime(String showtimeId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/showtimes/$showtimeId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _showtimes.removeWhere((st) => st['_id'] == showtimeId); // Cập nhật lại UI lập tức
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  Future<void> fetchStats(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/bookings/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _stats = jsonDecode(response.body);
      }
    } catch (e) {
      print('Lỗi fetch stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchAllBookings(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _allBookings = jsonDecode(response.body);
      }
    } catch (e) {
      print('Lỗi fetch tất cả bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
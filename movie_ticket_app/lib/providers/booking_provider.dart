import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; 
import '../models/showtime_model.dart';
import '../utils/constants.dart';

class BookingProvider with ChangeNotifier {
  List<Showtime> _showtimes = [];
  bool _isLoading = false;

  
  String? _lastBookingId;

  List<dynamic> _myBookings = [];

  
  List<Showtime> get showtimes => _showtimes;
  bool get isLoading => _isLoading;
  String? get lastBookingId => _lastBookingId; 
  List<dynamic> get myBookings => _myBookings;

  
  Future<void> fetchShowtimesByMovie(String movieId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
          Uri.parse('${AppConstants.baseUrl}/movies/$movieId/showtimes')
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _showtimes = data.map((json) => Showtime.fromJson(json)).toList();
      } else {
        _showtimes = [];
      }
    } catch (e) {
      print('Lỗi lấy suất chiếu: $e');
      _showtimes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 
  Future<bool> bookTickets(String showtimeId, List<String> seatsToBook, String token, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'showtimeId': showtimeId,
          'seatsToBook': seatsToBook,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        
        _lastBookingId = data['booking']['_id'];

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Lỗi đặt vé'), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể kết nối đến server'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  
  Future<void> fetchMyBookings(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/bookings/my-bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _myBookings = jsonDecode(response.body);
      }
    } catch (e) {
      print('Lỗi lấy lịch sử: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> processVNPayPayment(String bookingId, int amount, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/payment/create_url'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'bookingId': bookingId, 'amount': amount}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String paymentUrl = data['paymentUrl'];

       
        final Uri url = Uri.parse(paymentUrl);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Không thể mở cổng thanh toán');
        }
      }
    } catch (e) {
      print('Lỗi VNPay: $e');
    }
  }
}
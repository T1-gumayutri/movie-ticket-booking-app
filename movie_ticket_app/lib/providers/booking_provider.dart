import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Thư viện mở trình duyệt
import '../models/showtime_model.dart';
import '../utils/constants.dart';

class BookingProvider with ChangeNotifier {
  List<Showtime> _showtimes = [];
  bool _isLoading = false;

  // BIẾN MỚI THÊM: Lưu lại ID của vé vừa được đặt để truyền cho VNPay
  String? _lastBookingId;

  List<dynamic> _myBookings = [];

  // Getters
  List<Showtime> get showtimes => _showtimes;
  bool get isLoading => _isLoading;
  String? get lastBookingId => _lastBookingId; // Lấy ID vé ra
  List<dynamic> get myBookings => _myBookings;

  // ---------------------------------------------------
  // 1. LẤY DANH SÁCH SUẤT CHIẾU
  // ---------------------------------------------------
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

  // ---------------------------------------------------
  // 2. ĐẶT VÉ VÀ GIỮ CHỖ (GỌI API)
  // ---------------------------------------------------
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
        // [QUAN TRỌNG]: Lưu lại ID của cái vé vừa đặt thành công vào biến
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

  // ---------------------------------------------------
  // 3. LẤY LỊCH SỬ ĐẶT VÉ CỦA TÔI
  // ---------------------------------------------------
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

  // ---------------------------------------------------
  // 4. MỞ TRÌNH DUYỆT THANH TOÁN VNPAY
  // ---------------------------------------------------
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

        // Mở URL VNPay trên trình duyệt của điện thoại
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
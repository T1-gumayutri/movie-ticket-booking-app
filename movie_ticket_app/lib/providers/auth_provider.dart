import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  // Getters để các Widget khác có thể đọc dữ liệu
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // ---------------------------------------------------
  // 1. HÀM ĐĂNG NHẬP
  // ---------------------------------------------------
  Future<bool> login(String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        await _saveToken(_token!);       // Lưu token vào bộ nhớ máy
        await fetchUserProfile();        // Gọi API lấy thông tin Profile ngay lập tức

        _setLoading(false);
        return true; // Đăng nhập thành công
      } else {
        _showError(context, data['message'] ?? 'Lỗi đăng nhập');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _showError(context, 'Không thể kết nối đến server');
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------
  // 2. HÀM ĐĂNG KÝ
  // ---------------------------------------------------
  Future<bool> register(String name, String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        await _saveToken(_token!);
        await fetchUserProfile(); // Tự động lấy Profile sau khi đăng ký thành công

        _setLoading(false);
        return true;
      } else {
        _showError(context, data['message'] ?? 'Lỗi đăng ký');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _showError(context, 'Không thể kết nối đến server');
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------
  // 3. HÀM LẤY THÔNG TIN NGƯỜI DÙNG (PROFILE)
  // ---------------------------------------------------
  Future<void> fetchUserProfile() async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body);
        notifyListeners(); // Báo cho màn hình Profile cập nhật giao diện
      }
    } catch (e) {
      print("Lỗi lấy thông tin user: $e");
    }
  }

  // ---------------------------------------------------
  // 4. HÀM KIỂM TRA ĐĂNG NHẬP TỰ ĐỘNG (AUTO LOGIN)
  // ---------------------------------------------------
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return;

    _token = prefs.getString('jwt_token');
    await fetchUserProfile(); // Nạp lại Profile từ token đã lưu
    notifyListeners();
  }

  // ---------------------------------------------------
  // 5. HÀM ĐĂNG XUẤT
  // ---------------------------------------------------
  Future<void> logout() async {
    _token = null;
    _userData = null; // Xóa sạch thông tin Profile hiện tại
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Xóa token khỏi bộ nhớ máy
    notifyListeners(); // Kích hoạt sự kiện để MainScreen văng ra LoginScreen
  }

  // ---------------------------------------------------
  // CÁC HÀM TIỆN ÍCH HỖ TRỢ (PRIVATE METHODS)
  // ---------------------------------------------------

  // Lưu token vào local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Bật/tắt hiệu ứng xoay loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Hiển thị thông báo lỗi (SnackBar)
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
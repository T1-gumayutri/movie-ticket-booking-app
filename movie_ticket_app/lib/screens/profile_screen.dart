import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'admin_dashboard_screen.dart'; // Import màn hình Admin

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Lấy token và gọi API lấy lịch sử đặt vé khi màn hình được khởi tạo
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      Provider.of<BookingProvider>(context, listen: false).fetchMyBookings(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user và provider đặt vé
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userData;
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản & Vé của tôi'),
        // Nút đăng xuất trên AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // --- PHẦN 1: THÔNG TIN NGƯỜI DÙNG ---
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppConstants.cardColor,
                      child: const Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?['name'] ?? 'Người dùng',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?['email'] ?? 'Chưa cập nhật email',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- PHẦN 2: NÚT QUẢN TRỊ ADMIN (Chỉ hiện khi role = admin) ---
              if (user?['role'] == 'admin')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    border: Border.all(color: AppConstants.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: AppConstants.primaryColor, size: 30),
                    title: const Text(
                        'Khu Vực Quản Trị',
                        style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: const Text('Quản lý phim, suất chiếu, doanh thu', style: TextStyle(fontSize: 12, color: AppConstants.primaryColor)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppConstants.primaryColor),
                    onTap: () {
                      // Chuyển sang màn hình Admin Dashboard
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // --- PHẦN 3: TIÊU ĐỀ LỊCH SỬ ĐẶT VÉ ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lịch sử đặt vé',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- PHẦN 4: DANH SÁCH VÉ (DÙNG CONSUMER) ---
              Consumer<BookingProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  if (provider.myBookings.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('Bạn chưa có vé nào. Hãy đặt vé ngay nhé!')),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Quan trọng để ListView hoạt động trong SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Ngăn ListView tự cuộn
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.myBookings.length,
                    itemBuilder: (context, index) {
                      final booking = provider.myBookings[index];
                      final showtime = booking['showtime'];

                      // Xử lý an toàn khi suất chiếu bị xóa khỏi Database (Dữ liệu mồ côi)
                      if (showtime == null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppConstants.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Vé này thuộc về một suất chiếu đã bị xoá khỏi hệ thống.',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      // Dữ liệu an toàn
                      final movie = showtime['movie'] ?? {};
                      final String title = movie['title'] ?? 'Phim không xác định';
                      final String posterUrl = movie['posterUrl'] ?? '';

                      DateTime date = DateTime.now();
                      if (showtime['startTime'] != null) {
                        date = DateTime.parse(showtime['startTime']);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConstants.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Ảnh phim
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: posterUrl.startsWith('data:image')
                                  ? const Icon(Icons.movie, size: 50, color: Colors.grey)
                                  : (posterUrl.isNotEmpty
                                  ? Image.network(posterUrl, width: 60, height: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image, size: 50))
                                  : const Icon(Icons.image, size: 50, color: Colors.grey)),
                            ),
                            const SizedBox(width: 12),
                            // Thông tin vé
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(DateFormat('dd/MM/yyyy HH:mm').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text('Ghế: ${booking['seatsBooked'].join(', ')}', style: const TextStyle(color: AppConstants.primaryColor, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text('Tổng: ${currencyFormatter.format(booking['totalPrice'])}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.qr_code_2, size: 30, color: Colors.white70),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40), // Khoảng trống dưới cùng
            ],
          ),
        ),
      ),
    );
  }

  // --- HÀM HIỂN THỊ HỘP THOẠI ĐĂNG XUẤT ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Gọi hàm logout từ AuthProvider
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
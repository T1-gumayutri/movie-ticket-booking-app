import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'admin_movie_list_screen.dart';
import 'admin_user_list_screen.dart';
import 'admin_showtime_list_screen.dart';
import 'admin_stats_screen.dart';
import 'admin_booking_list_screen.dart';
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Điều Khiển Admin'),
        backgroundColor: AppConstants.backgroundColor,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminCard(context, Icons.movie, 'Quản lý Phim', Colors.blue),
          _buildAdminCard(context, Icons.event_seat, 'Quản lý Suất chiếu', Colors.orange),
          _buildAdminCard(context, Icons.people, 'Quản lý User', Colors.green),
          _buildAdminCard(context, Icons.receipt_long, 'Lịch sử Giao dịch', Colors.teal),
          _buildAdminCard(context, Icons.analytics, 'Thống kê', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, IconData icon, String title, Color color) {
    return InkWell(
      onTap: () {
        if (title == 'Quản lý Phim') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMovieListScreen()));
        }
        else if (title == 'Quản lý User') {
          
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserListScreen()));
        }
        else if (title == 'Quản lý Suất chiếu') {
          
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShowtimeListScreen()));
        }
        else if (title == 'Thống kê') {

          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStatsScreen()));
        }
        else if (title == 'Lịch sử Giao dịch') {

          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingListScreen()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
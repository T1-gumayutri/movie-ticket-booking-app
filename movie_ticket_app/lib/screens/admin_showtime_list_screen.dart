import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'admin_showtime_form.dart'; // Import cái form chúng ta làm ở bước trước

class AdminShowtimeListScreen extends StatefulWidget {
  const AdminShowtimeListScreen({super.key});

  @override
  State<AdminShowtimeListScreen> createState() => _AdminShowtimeListScreenState();
}

class _AdminShowtimeListScreenState extends State<AdminShowtimeListScreen> {
  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      Future.microtask(() => Provider.of<AdminProvider>(context, listen: false).fetchAllShowtimes(token));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Suất chiếu')),
      // Nút Nổi Thêm Suất Chiếu
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm Suất Chiếu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          // Bấm nút này sẽ mở trang Form mà bạn đã có code
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShowtimeForm()))
              .then((_) {
            // Sau khi đóng Form thêm, tải lại danh sách
            final token = Provider.of<AuthProvider>(context, listen: false).token!;
            Provider.of<AdminProvider>(context, listen: false).fetchAllShowtimes(token);
          });
        },
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.showtimes.isEmpty) return const Center(child: Text('Chưa có suất chiếu nào.'));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 16, left: 16, right: 16),
            itemCount: provider.showtimes.length,
            itemBuilder: (context, index) {
              final showtime = provider.showtimes[index];
              // Bảo vệ nếu lỡ movie bị xóa mà showtime vẫn còn
              final movieTitle = showtime['movie']?['title'] ?? 'Phim đã bị xóa';
              final startTime = DateTime.parse(showtime['startTime']);

              return Card(
                color: AppConstants.cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.event_seat, color: Colors.white),
                  ),
                  title: Text(movieTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rạp: ${showtime['theaterName']}'),
                      Text('Lịch: ${DateFormat('dd/MM/yyyy - HH:mm').format(startTime)}', style: const TextStyle(color: AppConstants.primaryColor)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, showtime['_id']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn huỷ suất chiếu này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = Provider.of<AuthProvider>(context, listen: false).token!;
              await Provider.of<AdminProvider>(context, listen: false).deleteShowtime(id, token);
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
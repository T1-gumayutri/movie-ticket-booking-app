import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminBookingListScreen extends StatefulWidget {
  const AdminBookingListScreen({super.key});

  @override
  State<AdminBookingListScreen> createState() => _AdminBookingListScreenState();
}

class _AdminBookingListScreenState extends State<AdminBookingListScreen> {
  @override
  void initState() {
    super.initState();
    
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      Future.microtask(() => Provider.of<AdminProvider>(context, listen: false).fetchAllBookings(token));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Đặt vé (Giao dịch)')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.allBookings.isEmpty) return const Center(child: Text('Chưa có giao dịch nào.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.allBookings.length,
            itemBuilder: (context, index) {
              final booking = provider.allBookings[index];

              
              final user = booking['user'] ?? {};
              final showtime = booking['showtime'] ?? {};
              final movie = showtime['movie'] ?? {};

              final userName = user['name'] ?? 'Khách đã xoá tài khoản';

             
              final movieTitle = booking['movieTitleSnapshot']
                  ?? movie['title']
                  ?? 'Phim đã bị xoá';

              final bookingDate = DateTime.parse(booking['createdAt']);

              return Card(
                color: AppConstants.cardColor,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          Text(DateFormat('dd/MM HH:mm').format(bookingDate), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),

                      
                      Text('Phim: $movieTitle', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('Ghế đặt: ${booking['seatsBooked'].join(', ')}', style: const TextStyle(color: AppConstants.primaryColor)),
                      const SizedBox(height: 6),

                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          currencyFormatter.format(booking['totalPrice'] ?? 0),
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
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
}
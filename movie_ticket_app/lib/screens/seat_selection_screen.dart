import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/showtime_model.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Showtime showtime;

  const SeatSelectionScreen({super.key, required this.showtime});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Danh sách lưu các ghế người dùng đang bấm chọn
  List<String> selectedSeats = [];
  final int ticketPrice = 80000; // Giá vé mặc định: 80k/ghế

  void _toggleSeat(String seatNumber, bool isBooked) {
    if (isBooked) return; // Ghế đã có người mua thì không cho bấm

    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber); // Bấm lần 2 là bỏ chọn
      } else {
        selectedSeats.add(seatNumber); // Bấm lần 1 là chọn
      }
    });
  }

  // [ĐÃ CẬP NHẬT LẠI HÀM NÀY]
  void _processBooking() async {
    if (selectedSeats.isEmpty) return;

    // 1. Lấy token từ AuthProvider
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    final provider = Provider.of<BookingProvider>(context, listen: false);

    // 2. Gọi API đặt vé (Lưu vé vào Database trước để giữ chỗ)
    final success = await provider.bookTickets(
        widget.showtime.id, selectedSeats, token, context);

    if (success && mounted) {
      // 3. Nếu đặt vé thành công và có mã Booking ID
      if (provider.lastBookingId != null) {
        // Báo cho người dùng biết đang chuyển hướng
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang chuyển hướng sang cổng thanh toán VNPay...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2), // Hiện 2 giây thôi
          ),
        );

        // Tính tổng tiền cần thanh toán
        final totalPrice = selectedSeats.length * ticketPrice;

        // Bắn dữ liệu sang VNPay và mở trình duyệt
        await provider.processVNPayPayment(provider.lastBookingId!, totalPrice, token);

        // Đóng màn hình chọn ghế, lùi thẳng về Home.
        // Khi khách hàng đóng trình duyệt VNPay, họ sẽ thấy màn hình trang chủ của App.
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<BookingProvider>(context).isLoading;
    // Format tiền tệ VND
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final totalPrice = selectedSeats.length * ticketPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn ghế ngồi')),
      body: Column(
        children: [
          // --- PHẦN 1: MÀN HÌNH CHIẾU (SCREEN) ---
          const SizedBox(height: 30),
          Container(
            height: 40,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              border: const Border(top: BorderSide(color: AppConstants.primaryColor, width: 4)),
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(50)), // Tạo độ cong
            ),
            alignment: Alignment.topCenter,
            child: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Màn hình', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 30),

          // --- PHẦN 2: LƯỚI GHẾ NGỒI ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // Mỗi hàng 5 ghế (A1 -> A5)
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.showtime.seats.length,
              itemBuilder: (context, index) {
                final seat = widget.showtime.seats[index];
                final isSelected = selectedSeats.contains(seat.seatNumber);

                // Quyết định màu ghế
                Color seatColor = Colors.grey[800]!; // Trống
                if (seat.isBooked) seatColor = Colors.white24; // Đã bán
                if (isSelected) seatColor = AppConstants.primaryColor; // Đang chọn

                return GestureDetector(
                  onTap: () => _toggleSeat(seat.seatNumber, seat.isBooked),
                  child: Container(
                    decoration: BoxDecoration(
                      color: seatColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      seat.seatNumber,
                      style: TextStyle(
                        color: seat.isBooked ? Colors.black54 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- PHẦN 3: CHÚ THÍCH (LEGEND) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.grey[800]!, 'Ghế trống'),
                _buildLegendItem(AppConstants.primaryColor, 'Đang chọn'),
                _buildLegendItem(Colors.white24, 'Đã bán'),
              ],
            ),
          ),

          // --- PHẦN 4: THANH TOÁN (CHECKOUT) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng tiền', style: TextStyle(color: Colors.grey)),
                    Text(
                      currencyFormatter.format(totalPrice),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedSeats.isEmpty ? Colors.grey : AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (selectedSeats.isEmpty || isLoading) ? null : _processBooking,
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Thanh Toán', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Hàm hỗ trợ vẽ chú thích nhỏ
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
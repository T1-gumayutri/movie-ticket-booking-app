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
  
  List<String> selectedSeats = [];
  final int ticketPrice = 80000; 

  void _toggleSeat(String seatNumber, bool isBooked) {
    if (isBooked) return; 

    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber); 
      } else {
        selectedSeats.add(seatNumber); 
      }
    });
  }

  
  void _processBooking() async {
    if (selectedSeats.isEmpty) return;

    
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    final provider = Provider.of<BookingProvider>(context, listen: false);

    
    final success = await provider.bookTickets(
        widget.showtime.id, selectedSeats, token, context);

    if (success && mounted) {
      
      if (provider.lastBookingId != null) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang chuyển hướng sang cổng thanh toán VNPay...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2), 
          ),
        );

        
        final totalPrice = selectedSeats.length * ticketPrice;

        
        await provider.processVNPayPayment(provider.lastBookingId!, totalPrice, token);

        
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<BookingProvider>(context).isLoading;
    
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final totalPrice = selectedSeats.length * ticketPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn ghế ngồi')),
      body: Column(
        children: [
          
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(50)), 
            ),
            alignment: Alignment.topCenter,
            child: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Màn hình', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 30),

          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, 
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.showtime.seats.length,
              itemBuilder: (context, index) {
                final seat = widget.showtime.seats[index];
                final isSelected = selectedSeats.contains(seat.seatNumber);

                
                Color seatColor = Colors.grey[800]!; 
                if (seat.isBooked) seatColor = Colors.white24; 
                if (isSelected) seatColor = AppConstants.primaryColor; 

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
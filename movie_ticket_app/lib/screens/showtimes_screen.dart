import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Dùng để format giờ (nhớ cài thư viện intl nếu chưa cài)
import '../models/movie_model.dart';
import '../providers/booking_provider.dart';
import '../utils/constants.dart';
import 'seat_selection_screen.dart'; // Thêm dòng này
class ShowtimesScreen extends StatefulWidget {
  final Movie movie;

  const ShowtimesScreen({super.key, required this.movie});

  @override
  State<ShowtimesScreen> createState() => _ShowtimesScreenState();
}

class _ShowtimesScreenState extends State<ShowtimesScreen> {
  @override
  void initState() {
    super.initState();
    // Vừa vào trang là tự động gọi API lấy suất chiếu của phim này
    Future.microtask(() =>
        Provider.of<BookingProvider>(context, listen: false)
            .fetchShowtimesByMovie(widget.movie.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }

          if (provider.showtimes.isEmpty) {
            return const Center(child: Text('Hiện tại chưa có suất chiếu cho phim này.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.showtimes.length,
            itemBuilder: (context, index) {
              final showtime = provider.showtimes[index];
              // Format thời gian thành dạng HH:mm (vd: 18:00)
              final formattedTime = DateFormat('HH:mm').format(showtime.startTime);
              final formattedDate = DateFormat('dd/MM/yyyy').format(showtime.startTime);

              return Card(
                color: AppConstants.cardColor,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showtime.theaterName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(formattedDate, style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Nút chọn giờ chiếu
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeatSelectionScreen(showtime: showtime),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppConstants.primaryColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            formattedTime,
                            style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            ),
                          ),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/movie_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminShowtimeForm extends StatefulWidget {
  const AdminShowtimeForm({super.key});

  @override
  State<AdminShowtimeForm> createState() => _AdminShowtimeFormState();
}

class _AdminShowtimeFormState extends State<AdminShowtimeForm> {
  final _formKey = GlobalKey<FormState>();

  String? selectedMovieId;
  final TextEditingController _theaterController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Đảm bảo danh sách phim đã được tải về để nhét vào Dropdown
    Future.microtask(() {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      if (movieProvider.movies.isEmpty) {
        movieProvider.fetchMovies();
      }
    });
  }

  @override
  void dispose() {
    _theaterController.dispose();
    super.dispose();
  }

  // --- Hàm Chọn Ngày ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- Hàm Chọn Giờ ---
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  // --- Hàm Gửi Dữ Liệu Lên Server ---
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedMovieId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phim!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Hợp nhất Ngày và Giờ thành 1 biến DateTime chuẩn ISO 8601 để gửi Backend
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Lấy Token của Admin
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    // Đóng gói dữ liệu gửi đi
    final showtimeData = {
      'movie': selectedMovieId,
      'theaterName': _theaterController.text.trim(),
      'startTime': combinedDateTime.toIso8601String(),
    };

    // Gọi API từ AdminProvider
    final success = await Provider.of<AdminProvider>(context, listen: false)
        .addShowtime(showtimeData, token);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm suất chiếu thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Quay lại trang danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi thêm suất chiếu!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe danh sách phim để đổ vào Dropdown
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Suất Chiếu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn Phim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // --- DROPDOWN CHỌN PHIM ---
              DropdownButtonFormField<String>(
                value: selectedMovieId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                hint: const Text('Bấm vào để chọn phim'),
                items: movieProvider.movies.map((movie) {
                  return DropdownMenuItem(
                    value: movie.id,
                    child: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedMovieId = val),
              ),
              const SizedBox(height: 20),

              const Text('Thông Tin Rạp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // --- TEXT INPUT TÊN RẠP ---
              TextFormField(
                controller: _theaterController,
                decoration: InputDecoration(
                  labelText: 'Tên Rạp (Ví dụ: CGV Landmark 81 - Rạp 1)',
                  filled: true,
                  fillColor: AppConstants.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập tên rạp' : null,
              ),
              const SizedBox(height: 20),

              const Text('Lịch Chiếu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // --- NÚT BẤM CHỌN NGÀY ---
              ListTile(
                tileColor: AppConstants.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                title: Text('Ngày chiếu: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 12),

              // --- NÚT BẤM CHỌN GIỜ ---
              ListTile(
                tileColor: AppConstants.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.access_time, color: AppConstants.primaryColor),
                title: Text('Giờ chiếu: ${_selectedTime.format(context)}'),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 40),

              // --- NÚT LƯU ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LƯU SUẤT CHIẾU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
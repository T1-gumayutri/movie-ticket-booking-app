import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie_model.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminMovieFormScreen extends StatefulWidget {
  final Movie? movie; // Nếu truyền vào là Sửa, không truyền là Thêm

  const AdminMovieFormScreen({super.key, this.movie});

  @override
  State<AdminMovieFormScreen> createState() => _AdminMovieFormScreenState();
}

class _AdminMovieFormScreenState extends State<AdminMovieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String title, description, posterUrl, genreString;
  late int duration;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Nếu có movie truyền vào (Chế độ Sửa), điền sẵn dữ liệu
    title = widget.movie?.title ?? '';
    description = widget.movie?.description ?? '';
    posterUrl = widget.movie?.posterUrl ?? '';
    duration = widget.movie?.duration ?? 120;
    genreString = widget.movie?.genre.join(', ') ?? ''; // Chuyển mảng thành chuỗi "Hành động, Hài"
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => isLoading = true);

    // Chuẩn bị dữ liệu gửi đi
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    final movieData = {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'duration': duration,
      'genre': genreString.split(',').map((e) => e.trim()).toList(), // Tách chuỗi thành mảng
      'releaseDate': DateTime.now().toIso8601String(), // Tạm mặc định là hôm nay
    };

    final provider = Provider.of<MovieProvider>(context, listen: false);
    bool success;

    if (widget.movie == null) {
      // CHẾ ĐỘ THÊM
      success = await provider.addMovie(movieData, token);
    } else {
      // CHẾ ĐỘ SỬA
      success = await provider.updateMovie(widget.movie!.id, movieData, token);
    }

    setState(() => isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      Navigator.pop(context); // Đóng form
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra!'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movie != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa Phim' : 'Thêm Phim Mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Tên phim', title, (val) => title = val!),
              const SizedBox(height: 16),
              _buildTextField('Link ảnh Poster (URL)', posterUrl, (val) => posterUrl = val!),
              const SizedBox(height: 16),
              _buildTextField('Thể loại (Cắt nhau bằng dấu phẩy)', genreString, (val) => genreString = val!),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: duration.toString(),
                decoration: InputDecoration(labelText: 'Thời lượng (Phút)', filled: true, fillColor: AppConstants.cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                keyboardType: TextInputType.number,
                onSaved: (val) => duration = int.tryParse(val!) ?? 120,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'Mô tả nội dung', filled: true, fillColor: AppConstants.cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                maxLines: 5,
                onSaved: (val) => description = val!,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('LƯU DỮ LIỆU', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initVal, Function(String?) onSaved) {
    return TextFormField(
      initialValue: initVal,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: AppConstants.cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      validator: (val) => val!.isEmpty ? 'Vui lòng nhập trường này' : null,
      onSaved: onSaved,
    );
  }
}
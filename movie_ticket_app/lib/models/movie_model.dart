class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final List<String> genre;
  final int duration;
  // THÊM BIẾN NÀY
  final bool isBase64Poster;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.genre,
    required this.duration,
    required this.isBase64Poster, // Cập nhật Constructor
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String rawPoster = json['posterUrl'] ?? '';

    // KIỂM TRA XEM CÓ PHẢI CHUỖI BASE64 KHÔNG
    bool isBase64 = rawPoster.startsWith('data:image');

    return Movie(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Không rõ tiêu đề',
      description: json['description'] ?? 'Đang cập nhật mô tả...',
      posterUrl: rawPoster,
      genre: json['genre'] != null
          ? List<String>.from(json['genre'])
          : ['Chưa phân loại'],
      duration: json['duration'] ?? 0,
      isBase64Poster: isBase64, // Gán giá trị
    );
  }
}
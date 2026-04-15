class Seat {
  final String seatNumber;
  final bool isBooked;

  Seat({required this.seatNumber, required this.isBooked});

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatNumber: json['seatNumber'] ?? '',
      isBooked: json['isBooked'] ?? false,
    );
  }
}

class Showtime {
  final String id;
  final String theaterName;
  final DateTime startTime;
  final List<Seat> seats;

  Showtime({
    required this.id,
    required this.theaterName,
    required this.startTime,
    required this.seats,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    var list = json['seats'] as List? ?? [];
    List<Seat> seatList = list.map((i) => Seat.fromJson(i)).toList();

    return Showtime(
      id: json['_id'] ?? '',
      theaterName: json['theaterName'] ?? 'Rạp chưa cập nhật',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      seats: seatList,
    );
  }
}
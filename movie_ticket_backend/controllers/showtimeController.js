const Showtime = require('../models/Showtime');

const createShowtime = async (req, res) => {
    try {
        const { movie, theaterName, startTime } = req.body;

        // Tự động tạo danh sách ghế (Ví dụ: 3 hàng A, B, C; mỗi hàng 5 ghế)
        const rows = ['A', 'B', 'C'];
        const seats = [];
        rows.forEach(row => {
            for (let i = 1; i <= 5; i++) {
                seats.push({ seatNumber: `${row}${i}`, isBooked: false });
            }
        });

        const newShowtime = new Showtime({
            movie,
            theaterName,
            startTime,
            seats // Gán mảng ghế vừa tạo vào đây
        });

        await newShowtime.save();
        res.status(201).json(newShowtime);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi tạo suất chiếu', error: error.message });
    }
};

const deleteShowtime = async (req, res) => {
    await Showtime.findByIdAndDelete(req.params.id);
    res.json({ message: 'Đã xóa suất chiếu' });
};
const getAllShowtimes = async (req, res) => {
    try {
        // populate('movie', 'title') giúp lấy tên phim thay vì chỉ lấy cái ID
        const showtimes = await Showtime.find()
            .populate('movie', 'title')
            .sort({ startTime: -1 }); // Xếp mới nhất lên đầu
        res.status(200).json(showtimes);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi lấy danh sách suất chiếu', error: error.message });
    }
};

module.exports = { createShowtime, deleteShowtime, getAllShowtimes };
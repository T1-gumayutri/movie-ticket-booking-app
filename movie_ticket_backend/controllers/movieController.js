const Movie = require('../models/Movie');
const Showtime = require('../models/Showtime');
// Lấy tất cả phim đang chiếu
const getMovies = async (req, res) => {
    try {
        const movies = await Movie.find();
        res.status(200).json(movies);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server khi lấy danh sách phim' });
    }
};
const getShowtimesByMovie = async (req, res) => {
    try {
        // 1. Lấy mốc thời gian hiện tại
        const currentTime = new Date();

        // 2. Query tìm suất chiếu với điều kiện lọc
        const showtimes = await Showtime.find({ 
            movie: req.params.movieId,
            // BÍ QUYẾT LÀ DÒNG NÀY: $gte (Greater Than or Equal) nghĩa là lớn hơn hoặc bằng
            startTime: { $gte: currentTime } 
        }).sort({ startTime: 1 }); // Tiện tay sắp xếp giờ chiếu tăng dần (từ sớm đến muộn) cho đẹp!

        res.status(200).json(showtimes);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi lấy suất chiếu', error: error.message });
    }
};
const createMovie = async (req, res) => {
    try {
        const { title, description, posterUrl, trailerUrl, duration, releaseDate, genre } = req.body;

        const movie = new Movie({
            title,
            description,
            posterUrl,
            trailerUrl,
            duration,
            releaseDate,
            genre
        });

        const createdMovie = await movie.save();
        res.status(201).json(createdMovie);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi tạo phim mới', error: error.message });
    }
};
   // Cập nhật phim (Chỉ Admin)
const updateMovie = async (req, res) => {
    try {
        const updatedMovie = await Movie.findByIdAndUpdate(
            req.params.movieId, 
            req.body, 
            { new: true, runValidators: true } // Trả về data mới nhất
        );
        if (!updatedMovie) return res.status(404).json({ message: 'Không tìm thấy phim' });
        res.status(200).json(updatedMovie);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi cập nhật phim', error: error.message });
    }
};

// Xóa phim (Chỉ Admin)
const deleteMovie = async (req, res) => {
    try {
        const movie = await Movie.findByIdAndDelete(req.params.movieId);
        if (!movie) return res.status(404).json({ message: 'Không tìm thấy phim' });
        res.status(200).json({ message: 'Đã xóa phim thành công' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi xóa phim', error: error.message });
    }
};

module.exports = { getMovies, getShowtimesByMovie, createMovie, updateMovie, deleteMovie };


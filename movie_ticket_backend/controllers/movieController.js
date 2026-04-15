const Movie = require('../models/Movie');
const Showtime = require('../models/Showtime');

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
        
        const currentTime = new Date();

        
        const showtimes = await Showtime.find({ 
            movie: req.params.movieId,
            
            startTime: { $gte: currentTime } 
        }).sort({ startTime: 1 }); 

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
   
const updateMovie = async (req, res) => {
    try {
        const updatedMovie = await Movie.findByIdAndUpdate(
            req.params.movieId, 
            req.body, 
            { new: true, runValidators: true } 
        );
        if (!updatedMovie) return res.status(404).json({ message: 'Không tìm thấy phim' });
        res.status(200).json(updatedMovie);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi cập nhật phim', error: error.message });
    }
};


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


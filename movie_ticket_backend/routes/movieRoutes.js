const express = require('express');
const router = express.Router();
const { getMovies, getShowtimesByMovie, createMovie } = require('../controllers/movieController');
const { protect, admin } = require('../middleware/authMiddleware'); // Import middleware
const { updateMovie, deleteMovie } = require('../controllers/movieController');
router.get('/', getMovies);
router.get('/:movieId/showtimes', getShowtimesByMovie);

// Gắn 2 lớp bảo vệ: Phải đăng nhập (protect) VÀ phải là Admin (admin)
router.post('/', protect, admin, createMovie); 
router.put('/:movieId', protect, admin, updateMovie); // Sửa
router.delete('/:movieId', protect, admin, deleteMovie); // Xóa
module.exports = router;
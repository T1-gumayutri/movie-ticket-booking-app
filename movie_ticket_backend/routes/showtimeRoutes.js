const express = require('express');
const router = express.Router();
const { createShowtime, deleteShowtime, getAllShowtimes } = require('../controllers/showtimeController');
const { protect, admin } = require('../middleware/authMiddleware');

// Lấy tất cả suất chiếu
router.get('/', protect, admin, getAllShowtimes);

// Thêm suất chiếu mới
router.post('/', protect, admin, createShowtime);

// Xóa suất chiếu
router.delete('/:id', protect, admin, deleteShowtime);

module.exports = router;
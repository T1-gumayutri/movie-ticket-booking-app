const express = require('express');
const router = express.Router();
const { createShowtime, deleteShowtime, getAllShowtimes } = require('../controllers/showtimeController');
const { protect, admin } = require('../middleware/authMiddleware');


router.get('/', protect, admin, getAllShowtimes);


router.post('/', protect, admin, createShowtime);


router.delete('/:id', protect, admin, deleteShowtime);

module.exports = router;
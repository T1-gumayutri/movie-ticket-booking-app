const express = require('express');
const router = express.Router();
const { getMovies, getShowtimesByMovie, createMovie } = require('../controllers/movieController');
const { protect, admin } = require('../middleware/authMiddleware'); 
const { updateMovie, deleteMovie } = require('../controllers/movieController');
router.get('/', getMovies);
router.get('/:movieId/showtimes', getShowtimesByMovie);


router.post('/', protect, admin, createMovie); 
router.put('/:movieId', protect, admin, updateMovie); 
router.delete('/:movieId', protect, admin, deleteMovie); 
module.exports = router;
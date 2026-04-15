const express = require('express');
const router = express.Router();

const { bookTicket, getMyBookings, getAdminStats, getAllBookings } = require('../controllers/bookingController');

const { protect, admin } = require('../middleware/authMiddleware'); 


router.get('/stats', protect, admin, getAdminStats);
router.get('/', protect, admin, getAllBookings);

router.post('/', protect, bookTicket); 
router.get('/my-bookings', protect, getMyBookings);
module.exports = router;
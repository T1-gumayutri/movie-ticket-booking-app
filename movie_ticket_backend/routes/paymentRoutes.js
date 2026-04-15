const express = require('express');
const router = express.Router();


const { createPaymentUrl, vnpayReturn, vnpayIPN } = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');


router.post('/create_url', protect, createPaymentUrl);


router.get('/vnpay_return', vnpayReturn);


router.get('/vnpay_ipn', vnpayIPN);

module.exports = router;
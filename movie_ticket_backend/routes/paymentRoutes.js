const express = require('express');
const router = express.Router();

// BỔ SUNG vnpayIPN VÀO DÒNG IMPORT NÀY:
const { createPaymentUrl, vnpayReturn, vnpayIPN } = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

// API Khách hàng gọi để lấy link thanh toán
router.post('/create_url', protect, createPaymentUrl);

// API VNPay gọi về để báo kết quả trực tiếp trên trình duyệt
router.get('/vnpay_return', vnpayReturn);

// API VNPay gọi ngầm để đồng bộ trạng thái đơn hàng (IPN)
router.get('/vnpay_ipn', vnpayIPN);

module.exports = router;
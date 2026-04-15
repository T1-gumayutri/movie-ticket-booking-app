const express = require('express');
const router = express.Router();
const { registerUser, loginUser, getMe } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', registerUser); // Endpoint: POST /api/auth/register
router.post('/login', loginUser);       // Endpoint: POST /api/auth/login
router.get('/me', protect, getMe);      // Endpoint: GET /api/auth/me (Cần token)

module.exports = router;
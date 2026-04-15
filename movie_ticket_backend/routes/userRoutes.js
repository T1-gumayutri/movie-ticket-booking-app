const express = require('express');
const router = express.Router();
const { getUsers, deleteUser } = require('../controllers/userController');
const { protect, admin } = require('../middleware/authMiddleware');

// Cả 2 route này đều phải đi qua chốt chặn "protect" (đăng nhập) và "admin"
router.get('/', protect, admin, getUsers);
router.delete('/:id', protect, admin, deleteUser);

module.exports = router;
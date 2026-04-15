const User = require('../models/User');

// Lấy danh sách tất cả user (Chỉ Admin)
const getUsers = async (req, res) => {
    try {
        // Lấy tất cả user nhưng KHÔNG lấy trường password để bảo mật
        const users = await User.find().select('-password');
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy danh sách người dùng' });
    }
};

// Xóa user (Chỉ Admin)
const deleteUser = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng' });

        // Không cho phép Admin tự xóa chính mình hoặc xóa Admin khác (chống sập hệ thống)
        if (user.role === 'admin') {
            return res.status(400).json({ message: 'Không thể xóa tài khoản Admin' });
        }

        await user.deleteOne();
        res.status(200).json({ message: 'Đã xóa người dùng thành công' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi xóa người dùng' });
    }
};

module.exports = { getUsers, deleteUser };
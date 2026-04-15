const User = require('../models/User');


const getUsers = async (req, res) => {
    try {
        
        const users = await User.find().select('-password');
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy danh sách người dùng' });
    }
};


const deleteUser = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng' });

        
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
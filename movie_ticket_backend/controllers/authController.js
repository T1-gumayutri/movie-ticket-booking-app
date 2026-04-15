const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Hàm hỗ trợ tạo JWT
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '2h', // Token có hạn 30 ngày
    });
};

// Đăng ký User mới
const registerUser = async (req, res) => {
    const { name, email, password } = req.body;

    try {
        // Kiểm tra xem user đã tồn tại chưa
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: 'Email này đã được đăng ký' });
        }

        // Mã hóa mật khẩu (Salt and Hash)
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Tạo user mới
        const user = await User.create({
            name,
            email,
            password: hashedPassword
        });

        if (user) {
            res.status(201).json({
                _id: user.id,
                name: user.name,
                email: user.email,
                token: generateToken(user._id)
            });
        } else {
            res.status(400).json({ message: 'Dữ liệu người dùng không hợp lệ' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
};

// Đăng nhập User
const loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        // Tìm user theo email
        const user = await User.findOne({ email });

        // Kiểm tra user và so sánh mật khẩu nhập vào với mật khẩu đã mã hóa trong DB
        if (user && (await bcrypt.compare(password, user.password))) {
            res.json({
                _id: user.id,
                name: user.name,
                email: user.email,
                token: generateToken(user._id)
            });
        } else {
            res.status(401).json({ message: 'Email hoặc mật khẩu không chính xác' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
};

// Lấy thông tin user hiện tại (Dùng để hiển thị Profile trên App Flutter)
const getMe = async (req, res) => {
    try {
        // req.user được lấy từ middleware bảo vệ
        const user = await User.findById(req.user.id).select('-password'); 
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
}

module.exports = { registerUser, loginUser, getMe };
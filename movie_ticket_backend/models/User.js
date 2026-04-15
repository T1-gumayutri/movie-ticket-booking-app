const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    name: { 
        type: String, 
        required: [true, 'Vui lòng nhập tên'] 
    },
    email: { 
        type: String, 
        required: [true, 'Vui lòng nhập email'], 
        unique: true,
        // Thêm Regex để validate định dạng chuẩn của Email
        match: [
            /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
            'Vui lòng nhập email hợp lệ (ví dụ: test@gmail.com)'
        ]
    },
    password: { 
        type: String, 
        required: [true, 'Vui lòng nhập mật khẩu'],
        // Ép mật khẩu phải từ 6 ký tự trở lên
        minlength: [6, 'Mật khẩu phải có ít nhất 6 ký tự']
    },
    role: {
        type: String,
        enum: ['user', 'admin'],
        default: 'user'
    }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
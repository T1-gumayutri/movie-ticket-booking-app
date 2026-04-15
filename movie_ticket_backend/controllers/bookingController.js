const mongoose = require('mongoose');
const Showtime = require('../models/Showtime');
const Booking = require('../models/Booking');
const User = require('../models/User');
const Movie = require('../models/Movie');

const bookTicket = async (req, res) => {
    const { showtimeId, seatsToBook } = req.body;

    // 1. Khởi tạo một Session cho Transaction
    const session = await mongoose.startSession();
    
    // Bắt đầu Transaction
    session.startTransaction();

    try {
        // --- CHỐT CHẶN BẢO MẬT: Không cho Admin đặt vé ---
        if (req.user.role === 'admin') {
            throw new Error('Tài khoản Admin không được phép thực hiện mua vé!');
        }
        // ---------------------------------------------------

        // 2. Tìm suất chiếu (BẮT BUỘC phải truyền session vào query)
        const showtime = await Showtime.findById(showtimeId).populate('movie').session(session);
        if (!showtime) {
            throw new Error('Không tìm thấy suất chiếu');
        }

        // 3. Kiểm tra ghế (Logic giữ nguyên nhưng chạy trong môi trường an toàn)
        let isAvailable = true;
        showtime.seats.forEach(seat => {
            if (seatsToBook.includes(seat.seatNumber) && seat.isBooked) {
                isAvailable = false;
            }
        });

        if (!isAvailable) {
            // Ném lỗi để nhảy xuống catch block, hủy transaction
            throw new Error('Ghế đã có người đặt, vui lòng chọn ghế khác');
        }

        // 4. Cập nhật trạng thái ghế
        showtime.seats.forEach(seat => {
            if (seatsToBook.includes(seat.seatNumber)) {
                seat.isBooked = true;
            }
        });
        
        // Lưu thay đổi của Showtime kèm theo session
        await showtime.save({ session });

        // 5. Tạo hóa đơn Booking
        const ticketPrice = 80000; 
        
        // [CẬP NHẬT]: Lấy tên phim để lưu cứng vào vé. Đề phòng trường hợp phim bị lỗi không lấy được thì gán tên mặc định.
        const snapshotTitle = showtime.movie ? showtime.movie.title : 'Phim không xác định';
        
        // Lưu ý: Dùng mảng [{...}] khi dùng create() với session trong Mongoose
        const newBooking = await Booking.create([{
            user: req.user.id,
            showtime: showtimeId,
            seatsBooked: seatsToBook,
            totalPrice: seatsToBook.length * ticketPrice,
            movieTitleSnapshot: snapshotTitle // Gắn cứng tên phim vào đây để lưu vết
        }], { session });

        // 6. XÁC NHẬN GIAO DỊCH (Commit) - Mọi thứ thành công, lưu vĩnh viễn vào DB
        await session.commitTransaction();
        session.endSession();

        res.status(201).json({ 
            message: 'Đặt vé thành công', 
            booking: newBooking[0] // Vì create với session trả về mảng
        });

    } catch (error) {
        // 7. HỦY GIAO DỊCH (Abort) - Nếu có bất kỳ lỗi gì ở trên, mọi thay đổi sẽ bị rollback (quay xe)
        await session.abortTransaction();
        session.endSession();

        // Xử lý mã lỗi để trả về cho Frontend
        const statusCode = error.message.includes('Không tìm thấy') ? 404 : 400;
        res.status(statusCode).json({ message: error.message });
    }
};

// Lấy lịch sử đặt vé của User đang đăng nhập
const getMyBookings = async (req, res) => {
    try {
        // Tìm các booking của user này, đồng thời lấy thêm thông tin của Suất chiếu và Phim (populate)
        const bookings = await Booking.find({ user: req.user.id })
            .populate({
                path: 'showtime',
                populate: { path: 'movie', select: 'title posterUrl' } // Lấy tên phim và ảnh để hiển thị
            })
            .sort({ createdAt: -1 }); // Vé mới nhất hiện lên đầu

        res.status(200).json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy lịch sử đặt vé', error: error.message });
    }
};

// Lấy thống kê cho Admin
const getAdminStats = async (req, res) => {
    try {
        // Tổng doanh thu và số vé
        const bookingStats = await Booking.aggregate([
            {
                $group: {
                    _id: null,
                    totalRevenue: { $sum: '$totalPrice' },
                    totalSeatsSold: { $sum: { $size: '$seatsBooked' } }
                }
            }
        ]);

        const totalRevenue = bookingStats.length > 0 ? bookingStats[0].totalRevenue : 0;
        const totalSeatsSold = bookingStats.length > 0 ? bookingStats[0].totalSeatsSold : 0;

        // Tổng User và Phim
        const totalUsers = await User.countDocuments({ role: 'user' });
        const totalMovies = await Movie.countDocuments();

        // Biểu đồ: Thống kê 7 ngày qua
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        const dailyRevenue = await Booking.aggregate([
            { $match: { createdAt: { $gte: sevenDaysAgo } } },
            {
                $group: {
                    _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                    revenue: { $sum: '$totalPrice' }
                }
            },
            { $sort: { _id: 1 } }
        ]);

        res.status(200).json({
            totalRevenue,
            totalSeatsSold,
            totalUsers,
            totalMovies,
            dailyRevenue
        });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi thống kê', error: error.message });
    }
};

// Lấy toàn bộ danh sách đặt vé của hệ thống
const getAllBookings = async (req, res) => {
    try {
        const bookings = await Booking.find()
            .populate('user', 'name email') // Lấy thêm tên và email của khách hàng
            .populate({
                path: 'showtime',
                populate: { path: 'movie', select: 'title' } // Lấy tên phim (fallback nếu cần)
            })
            .sort({ createdAt: -1 }); // Vé mới nhất đẩy lên đầu

        res.status(200).json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi lấy danh sách đặt vé', error: error.message });
    }
};

module.exports = { bookTicket, getMyBookings, getAdminStats, getAllBookings };
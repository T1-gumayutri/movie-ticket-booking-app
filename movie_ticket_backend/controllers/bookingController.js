const mongoose = require('mongoose');
const Showtime = require('../models/Showtime');
const Booking = require('../models/Booking');
const User = require('../models/User');
const Movie = require('../models/Movie');

const bookTicket = async (req, res) => {
    const { showtimeId, seatsToBook } = req.body;

    
    const session = await mongoose.startSession();
    
    
    session.startTransaction();

    try {
        
        if (req.user.role === 'admin') {
            throw new Error('Tài khoản Admin không được phép thực hiện mua vé!');
        }
        
        const showtime = await Showtime.findById(showtimeId).populate('movie').session(session);
        if (!showtime) {
            throw new Error('Không tìm thấy suất chiếu');
        }

        
        let isAvailable = true;
        showtime.seats.forEach(seat => {
            if (seatsToBook.includes(seat.seatNumber) && seat.isBooked) {
                isAvailable = false;
            }
        });

        if (!isAvailable) {
            
            throw new Error('Ghế đã có người đặt, vui lòng chọn ghế khác');
        }

        
        showtime.seats.forEach(seat => {
            if (seatsToBook.includes(seat.seatNumber)) {
                seat.isBooked = true;
            }
        });
        
        
        await showtime.save({ session });

        
        const ticketPrice = 80000; 
        
       
        const snapshotTitle = showtime.movie ? showtime.movie.title : 'Phim không xác định';
        
        
        const newBooking = await Booking.create([{
            user: req.user.id,
            showtime: showtimeId,
            seatsBooked: seatsToBook,
            totalPrice: seatsToBook.length * ticketPrice,
            movieTitleSnapshot: snapshotTitle 
        }], { session });

        
        await session.commitTransaction();
        session.endSession();

        res.status(201).json({ 
            message: 'Đặt vé thành công', 
            booking: newBooking[0] 
        });

    } catch (error) {
        
        await session.abortTransaction();
        session.endSession();

       
        const statusCode = error.message.includes('Không tìm thấy') ? 404 : 400;
        res.status(statusCode).json({ message: error.message });
    }
};


const getMyBookings = async (req, res) => {
    try {
        
        const bookings = await Booking.find({ user: req.user.id })
            .populate({
                path: 'showtime',
                populate: { path: 'movie', select: 'title posterUrl' } 
            })
            .sort({ createdAt: -1 }); 
        res.status(200).json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy lịch sử đặt vé', error: error.message });
    }
};


const getAdminStats = async (req, res) => {
    try {
        
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

        
        const totalUsers = await User.countDocuments({ role: 'user' });
        const totalMovies = await Movie.countDocuments();

       
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


const getAllBookings = async (req, res) => {
    try {
        const bookings = await Booking.find()
            .populate('user', 'name email') 
            .populate({
                path: 'showtime',
                populate: { path: 'movie', select: 'title' } 
            })
            .sort({ createdAt: -1 }); 

        res.status(200).json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi lấy danh sách đặt vé', error: error.message });
    }
};

module.exports = { bookTicket, getMyBookings, getAdminStats, getAllBookings };
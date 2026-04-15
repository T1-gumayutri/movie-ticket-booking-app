const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    showtime: { type: mongoose.Schema.Types.ObjectId, ref: 'Showtime', required: true },
    seatsBooked: [{ type: String, required: true }], 
    totalPrice: { type: Number, required: true },
    movieTitleSnapshot:{ type: String,},
    status: { type: String, enum: ['Thành công', 'Đã hủy'], default: 'Thành công' }
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
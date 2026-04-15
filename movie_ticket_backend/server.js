const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

// Load biến môi trường
dotenv.config();

// Kết nối DB
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json()); // Xử lý JSON body

// Test route
app.get('/', (req, res) => {
    res.send('Movie Ticket API is running...');
});
app.use('/api/auth', require('./routes/authRoutes'));
app.use("/api/movies",require("./routes/movieRoutes"));
app.use("/api/bookings",require("./routes/bookingRoutes"));
app.use('/api/users', require('./routes/userRoutes')); // Thêm dòng này
app.use('/api/showtimes', require('./routes/showtimeRoutes'));
app.use('/api/payment', require('./routes/paymentRoutes'));
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server is running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});
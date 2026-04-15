const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');


dotenv.config();


connectDB();

const app = express();


app.use(cors());
app.use(express.json()); 


app.get('/', (req, res) => {
    res.send('Movie Ticket API is running...');
});
app.use('/api/auth', require('./routes/authRoutes'));
app.use("/api/movies",require("./routes/movieRoutes"));
app.use("/api/bookings",require("./routes/bookingRoutes"));
app.use('/api/users', require('./routes/userRoutes')); 
app.use('/api/showtimes', require('./routes/showtimeRoutes'));
app.use('/api/payment', require('./routes/paymentRoutes'));
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server is running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});
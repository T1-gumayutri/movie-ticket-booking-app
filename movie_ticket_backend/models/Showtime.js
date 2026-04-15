const mongoose = require("mongoose");

const showtimeSchema = new mongoose.Schema({
    movie: { type: mongoose.Schema.Types.ObjectId, ref: 'Movie', required: true },
    theaterName: { type: String, required: true },
    startTime: { type: Date, required: true },
    seats:[{
        seatNumber:{
            type:String,
            required:true,
        },
        isBooked:{
            type:Boolean,
            default:false,
        }
    }]
})
module.exports = mongoose.model("Showtime",showtimeSchema)
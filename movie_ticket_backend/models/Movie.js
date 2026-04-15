const mongoose = require('mongoose');

const movieSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String, required: true },
    posterUrl: { type: String, required: true },
    trailerUrl: { type: String }, 
    genre: [{ type: String }],
    
    // BẠN ĐANG THIẾU DÒNG NÀY 👇
    duration: { type: Number, required: true, default: 120 }, 
    
    releaseDate: { type: Date }
}, {
    timestamps: true
});

module.exports = mongoose.model('Movie', movieSchema);
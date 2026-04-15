const crypto = require('crypto');
const moment = require('moment');
const qs = require('qs');
const Booking = require('../models/Booking');
const Showtime = require('../models/Showtime'); // Import Showtime để xử lý ghế

function sortObject(obj) {
    let sorted = {};
    let str = [];
    let key;
    for (key in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, key)) {
            str.push(encodeURIComponent(key));
        }
    }
    str.sort();
    for (key = 0; key < str.length; key++) {
        sorted[str[key]] = encodeURIComponent(obj[str[key]]).replace(/%20/g, "+");
    }
    return sorted;
}

const createPaymentUrl = async (req, res) => {
    try {
        const { bookingId, amount } = req.body;
        
        let date = new Date();
        let createDate = moment(date).format('YYYYMMDDHHmmss');
        let ipAddr = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress || '127.0.0.1';

        let tmnCode = process.env.VNP_TMNCODE;
        let secretKey = process.env.VNP_HASHSECRET;
        let vnpUrl = process.env.VNP_URL;
        let returnUrl = process.env.VNP_RETURN_URL;
        
        let orderId = bookingId; 
        
        let vnp_Params = {};
        vnp_Params['vnp_Version'] = '2.1.0';
        vnp_Params['vnp_Command'] = 'pay';
        vnp_Params['vnp_TmnCode'] = tmnCode;
        vnp_Params['vnp_Locale'] = 'vn';
        vnp_Params['vnp_CurrCode'] = 'VND';
        vnp_Params['vnp_TxnRef'] = orderId;
        vnp_Params['vnp_OrderInfo'] = 'Thanh toan ve xem phim: ' + orderId;
        vnp_Params['vnp_OrderType'] = 'other';
        vnp_Params['vnp_Amount'] = amount * 100; 
        vnp_Params['vnp_ReturnUrl'] = returnUrl;
        vnp_Params['vnp_IpAddr'] = ipAddr;
        vnp_Params['vnp_CreateDate'] = createDate;

        vnp_Params = sortObject(vnp_Params);

        let signData = qs.stringify(vnp_Params, { encode: false });
        let hmac = crypto.createHmac("sha512", secretKey);
        let signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex"); 
        vnp_Params['vnp_SecureHash'] = signed;
        vnpUrl += '?' + qs.stringify(vnp_Params, { encode: false });

        res.status(200).json({ paymentUrl: vnpUrl });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi tạo URL thanh toán', error: error.message });
    }
};

// --- HÀM HỖ TRỢ: NHẢ GHẾ (ROLLBACK) KHI THANH TOÁN LỖI ---
const rollbackBooking = async (orderId) => {
    try {
        const booking = await Booking.findById(orderId);
        // Nếu tìm thấy vé và vé này chưa được thanh toán
        if (booking && !booking.isPaid) {
            const showtime = await Showtime.findById(booking.showtime);
            if (showtime) {
                // Duyệt qua tất cả các ghế, ghế nào có trong vé này thì nhả ra (isBooked = false)
                showtime.seats.forEach(seat => {
                    if (booking.seatsBooked.includes(seat.seatNumber)) {
                        seat.isBooked = false;
                    }
                });
                await showtime.save();
            }
            // Xoá luôn cái hoá đơn nháp này khỏi Database cho sạch
            await Booking.findByIdAndDelete(orderId);
        }
    } catch (error) {
        console.error('Lỗi nhả ghế:', error);
    }
};

const vnpayReturn = async (req, res) => {
    let vnp_Params = req.query;
    let secureHash = vnp_Params['vnp_SecureHash'];

    delete vnp_Params['vnp_SecureHash'];
    delete vnp_Params['vnp_SecureHashType'];

    vnp_Params = sortObject(vnp_Params);
    let secretKey = process.env.VNP_HASHSECRET;
    let signData = qs.stringify(vnp_Params, { encode: false });
    let hmac = crypto.createHmac("sha512", secretKey);
    let signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");     

    if(secureHash === signed){
        let orderId = vnp_Params['vnp_TxnRef'];

        if (vnp_Params['vnp_ResponseCode'] == '00') {
            // THÀNH CÔNG: Chốt đơn
            await Booking.findByIdAndUpdate(orderId, { isPaid: true });
            res.send('<h1 style="color: green; text-align: center; margin-top: 50px;">Thanh toán thành công! Vui lòng quay lại ứng dụng.</h1>');
        } else {
            // THẤT BẠI HOẶC HUỶ BỎ: Gọi hàm nhả ghế
            await rollbackBooking(orderId);
            res.send('<h1 style="color: red; text-align: center; margin-top: 50px;">Giao dịch đã bị huỷ. Ghế của bạn đã được nhả ra!</h1>');
        }
    } else {
        res.send('<h1 style="color: red; text-align: center;">Lỗi chữ ký bảo mật!</h1>');
    }
};

const vnpayIPN = async (req, res) => {
    let vnp_Params = req.query;
    let secureHash = vnp_Params['vnp_SecureHash'];

    delete vnp_Params['vnp_SecureHash'];
    delete vnp_Params['vnp_SecureHashType'];

    vnp_Params = sortObject(vnp_Params); 
    let secretKey = process.env.VNP_HASHSECRET;
    let signData = qs.stringify(vnp_Params, { encode: false });
    let hmac = crypto.createHmac("sha512", secretKey);
    let signed = hmac.update(Buffer.from(signData, 'utf-8')).digest("hex");

    if (secureHash === signed) {
        let orderId = vnp_Params['vnp_TxnRef'];
        let rspCode = vnp_Params['vnp_ResponseCode'];

        if (rspCode === '00') {
            // THÀNH CÔNG
            await Booking.findByIdAndUpdate(orderId, { isPaid: true });
            res.status(200).json({ RspCode: '00', Message: 'Success' });
        } else {
            // THẤT BẠI: Gọi hàm nhả ghế
            await rollbackBooking(orderId);
            res.status(200).json({ RspCode: '00', Message: 'Success' }); // Vẫn trả 00 cho VNPay để xác nhận đã nhận thông tin
        }
    } else {
        res.status(200).json({ RspCode: '97', Message: 'Fail checksum' });
    }
};

module.exports = { createPaymentUrl, vnpayReturn, vnpayIPN };
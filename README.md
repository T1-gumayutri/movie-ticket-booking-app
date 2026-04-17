# 🎬 Ứng dụng Đặt Vé Xem Phim (Movie Ticket App)

Một ứng dụng di động đa nền tảng (iOS & Android) được xây dựng bằng Flutter, cho phép người dùng dễ dàng duyệt phim, xem lịch chiếu và đặt vé xem phim trực tuyến. Ứng dụng cũng tích hợp một hệ thống quản trị (Admin Dashboard) ngay bên trong để quản lý rạp phim.

---

## ✨ Tính năng nổi bật

### 👤 Dành cho Người dùng (User)
*   **Xác thực người dùng:** Đăng ký, đăng nhập và quản lý tài khoản cá nhân một cách an toàn.
*   **Duyệt Phim:** Xem danh sách các bộ phim đang chiếu, sắp chiếu với thông tin chi tiết, poster trực quan nhờ slider sống động.
*   **Lịch chiếu & Đặt vé:** Chọn suất chiếu phù hợp, chọn vị trí ghế ngồi và tiến hành đặt vé.
*   **Quản lý vé:** Xem lại lịch sử đặt vé, chi tiết vé đã mua ngay trong ứng dụng (tích hợp giao diện QR code).
*   **Giao diện thân thiện:** UI/UX hiện đại, hỗ trợ định dạng tiền tệ Việt Nam (VNĐ).

### 🛠 Dành cho Quản trị viên (Admin)
*   **Phân quyền Admin:** Tự động nhận diện tài khoản Admin để hiển thị Khu vực Quản trị.
*   **Quản lý Phim:** Thêm, sửa, xóa thông tin các bộ phim.
*   **Quản lý Suất chiếu:** Lên lịch chiếu cho các bộ phim tại các phòng chiếu khác nhau.
*   **Thống kê & Doanh thu:** Xem báo cáo doanh thu, số lượng vé bán ra trực quan hóa bằng biểu đồ.

---

## 💻 Công nghệ sử dụng (Tech Stack)

*   **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.11.3)
*   **Ngôn ngữ:** Dart
*   **State Management:** `provider`
*   **Giao tiếp Mạng:** `http` (Tương tác với REST API)
*   **Lưu trữ Local:** `shared_preferences` (Lưu trữ Token, thông tin user cơ bản)
*   **Giao diện & Biểu đồ:**
    *   `carousel_slider`: Hiển thị slider phim ấn tượng ở trang chủ.
    *   `fl_chart`: Vẽ biểu đồ thống kê doanh thu cho Admin.
    *   `google_fonts`: Tùy chỉnh font chữ.
    *   `cupertino_icons`: Bộ icon phong cách.
*   **Tiện ích:**
    *   `intl`: Format ngày tháng, tiền tệ.
    *   `url_launcher`: Mở liên kết web bên ngoài.

---

## 🚀 Hướng dẫn cài đặt (Getting Started)

### Yêu cầu hệ thống (Prerequisites)
*   Đã cài đặt Flutter SDK phiên bản mới nhất.
*   IDE: Android Studio / VS Code (có cài đặt Flutter & Dart plugins).
*   Máy ảo Android/iOS (Simulator/Emulator) hoặc thiết bị thật.

### Các bước chạy dự án
1.  **Clone dự án về máy:**
    ```bash
    git clone https://github.com/T1-gumayutri/movie-ticket-booking-app.git
    cd App_Dat_Ve_Phim/movie_ticket_app
    ```

2.  **Cài đặt các dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Cấu hình API (Nếu có):**
    *   Mở file quản lý hằng số (ví dụ: `lib/utils/constants.dart`).
    *   Thay đổi địa chỉ Base URL trỏ về máy chủ backend thực tế của bạn.

4.  **Chạy ứng dụng:**
    ```bash
    flutter run
    ```

---

## 📂 Cấu trúc thư mục dự án

```text
movie_ticket_app/
│
├── lib/
│   ├── main.dart               # Điểm bắt đầu của ứng dụng
│   ├── providers/              # Xử lý State Management (AuthProvider, BookingProvider,...)
│   ├── screens/                # Giao diện người dùng (HomeScreen, ProfileScreen, AdminDashboardScreen,...)
│   ├── utils/                  # Các hằng số, màu sắc, cấu hình chung (constants.dart)
│   └── widgets/                # Các UI component có thể tái sử dụng
│
├── assets/
│   └── images/                 # Hình ảnh tĩnh cục bộ
│
├── pubspec.yaml                # Quản lý thư viện và tài nguyên của Flutter
└── analysis_options.yaml       # Cấu hình linter kiểm tra lỗi code
```

---


## 🤝 Đóng góp (Contributing)
Nếu bạn muốn đóng góp để ứng dụng hoàn thiện hơn, vui lòng:
1. Fork repository này.
2. Tạo một branch mới (`git checkout -b feature/TinhNangMoi`).
3. Commit những thay đổi của bạn (`git commit -m 'Thêm tính năng XYZ'`).
4. Push lên branch (`git push origin feature/TinhNangMoi`).
5. Tạo một Pull Request.




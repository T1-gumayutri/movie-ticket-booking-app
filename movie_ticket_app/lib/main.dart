import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'providers/booking_provider.dart'; // Thêm dòng này lên đầu
import 'screens/home_screen.dart';
import 'providers/movie_provider.dart';
import 'providers/admin_provider.dart';
void main() {
  runApp(
    // Bọc app bằng MultiProvider để cung cấp AuthProvider cho toàn bộ ứng dụng
    // Trong main.dart, sửa lại MultiProvider:
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),// THÊM DÒNG NÀY
      ],
      child: const MovieTicketApp(),
    ),
  );
}

class MovieTicketApp extends StatelessWidget {
  const MovieTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Ticket Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        primaryColor: AppConstants.primaryColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: AppConstants.textColor,
          displayColor: AppConstants.textColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          elevation: 0,
        ),
      ),
      // FutureBuilder giúp chạy hàm tryAutoLogin (kiểm tra token) trước khi load UI
      home: FutureBuilder(
        future: Provider.of<AuthProvider>(context, listen: false).tryAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Màn hình chờ (Splash Screen) trong lúc lấy token từ máy
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Lắng nghe trạng thái Auth. Nếu có token -> HomeScreen, không có -> LoginScreen
          return Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return auth.isAuthenticated ? const MainScreen() : const LoginScreen();
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // โหลด session ที่บันทึกไว้ก่อนเปิดแอป
  await AuthService().loadSession();
  runApp(const JapanTravelApp());
}

class JapanTravelApp extends StatelessWidget {
  const JapanTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ถ้ายังไม่ได้ login → ไปหน้า Login
    // ถ้า login แล้ว → ไปหน้า Home
    final bool loggedIn = AuthService().isLoggedIn;

    return MaterialApp(
      title: 'เที่ยวญี่ปุ่น',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: loggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}

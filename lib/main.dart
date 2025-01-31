import 'package:flutter/material.dart';
import 'package:velitt/screens/splash_screen.dart';
import 'package:velitt/theme/app_theme.dart';
import 'package:velitt/screens/login_screen.dart';
import 'package:velitt/screens/dashboard_screen.dart';
import 'package:velitt/screens/member_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velitt',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        // '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/member_dashboard': (context) => const MemberDashboardScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
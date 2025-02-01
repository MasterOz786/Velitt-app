
import 'package:flutter/material.dart';
import 'package:velitt/screens/home_screen.dart'; 
import 'package:velitt/screens/profile_information_screen.dart';
import 'package:velitt/screens/splash_screen.dart';
import 'package:velitt/theme/app_theme.dart';
import 'package:velitt/screens/login_screen.dart';
import 'package:velitt/screens/dashboard_screen.dart';
import 'package:velitt/screens/member_dashboard_screen.dart';
import 'package:velitt/screens/profile_screen.dart';
import 'package:velitt/screens/wallet_screen.dart';
import 'package:velitt/screens/coupons_screen.dart';
import 'package:velitt/screens/challenges_screen.dart'; // Import the new screen

import 'package:velitt/screens/logger.dart';

void main() {
  setupLogging();
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
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/personal_information': (context) => const ProfileInformationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/member_dashboard': (context) => const MemberDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/coupons': (context) => const CouponsScreen(),
        '/challenges': (context) => const ChallengesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
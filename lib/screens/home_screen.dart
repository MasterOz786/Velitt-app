import 'package:flutter/material.dart';
import 'package:velitt/screens/member_dashboard_screen.dart';
import 'package:velitt/screens/wallet_screen.dart';
import 'package:velitt/screens/member_videos_screen.dart';
import 'package:velitt/screens/challenges_screen.dart';
import 'package:velitt/screens/profile_screen.dart';
import 'package:velitt/widgets/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MemberDashboardScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MemberVideosScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ChallengesScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://placeholder.com/80x80'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Welcome Back!', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const Text('Ejaz Uddin', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Options Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGridItem('Member Dashboard', Icons.dashboard, context, 0),
                  _buildGridItem('Wallet', Icons.account_balance_wallet, context, 1),
                  _buildGridItem('Member Videos', Icons.video_library, context, 2),
                  _buildGridItem('Challenges', Icons.flag, context, 3),
                  _buildGridItem('Member Profile', Icons.person, context, 4),
                ],
              ),
            ),
            // Bottom Navigation
            BottomNavBar(currentIndex: 0, onTap: _handleNavigation),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon, BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE31E24), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velitt/widgets/bottom_navbar.dart'; // Import the BottomNavBar widget
import 'package:velitt/widgets/header.dart';
import 'package:velitt/state/member_state.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _onMenuItemTap(String route) {
    Navigator.pushNamed(context, route);
  }

  Widget _buildMenuItem(String title, String iconPath, Color backgroundColor, String route) {
    return InkWell(
      onTap: () => _onMenuItemTap(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE31E24), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(iconPath, width: 160, height: 120),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MemberState memberState = Provider.of<MemberState>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: 'Dashboard',
              memberName: memberState.memberName ?? 'None',
              profileImage: memberState.profileImage ?? 'https://via.placeholder.com/160',
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(24),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuItem('Dashboard', 'assets/icons/Dashboard.png', Colors.blue.shade900, '/dashboard'),
                  _buildMenuItem('Wallet', 'assets/icons/Wallet.png', Colors.purple.shade900, '/wallet'),
                  _buildMenuItem('Videos', 'assets/icons/Videos.png', Colors.red.shade900, '/videos'),
                  _buildMenuItem('Challenges', 'assets/icons/Challenges.png', Colors.orange.shade900, '/challenges'),
                  _buildMenuItem('Profile', 'assets/icons/Profile.png', Colors.green.shade900, '/profile'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex, onTap: _handleNavigation),
    );
  }
}

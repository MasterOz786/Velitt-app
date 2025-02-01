import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('Home', 'assets/icons/Home.png', 0),
          _buildNavItem('Dashboard', 'assets/icons/Dashboard.png', 1),
          _buildNavItem('Profile', 'assets/icons/Profile.png', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, String iconPath, int index) {
    final bool isActive = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE31E24) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              // color: Colors.white, // Apply white tint to match theme
              width: 48,
              height: 48,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

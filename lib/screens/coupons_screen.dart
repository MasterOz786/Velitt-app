import 'package:flutter/material.dart';
import 'package:velitt/widgets/bottom_navbar.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/wallet');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
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
            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Text(
                    'BALANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://raw.githubusercontent.com/your-repo/assets/main/coin_icon.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '150',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.network(
                        'https://raw.githubusercontent.com/your-repo/assets/main/mascot.png',
                        width: 60,
                        height: 60,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready to redeem',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Coupons List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _CouponCard(
                    logo: 'https://raw.githubusercontent.com/your-repo/assets/main/digicel_logo.png',
                    name: 'Digicel',
                  ),
                  _CouponCard(
                    logo: 'https://raw.githubusercontent.com/your-repo/assets/main/chippie_logo.png',
                    name: 'Chippie',
                  ),
                  _CouponCard(
                    logo: 'https://raw.githubusercontent.com/your-repo/assets/main/kla_logo.png',
                    name: 'Kla Mobile',
                  ),
                  _CouponCard(
                    logo: 'https://raw.githubusercontent.com/your-repo/assets/main/digicel_logo.png',
                    name: 'Digicel',
                  ),
                  _CouponCard(
                    logo: 'https://raw.githubusercontent.com/your-repo/assets/main/pagatinu_logo.png',
                    name: 'Pagatinu',
                  ),
                ],
              ),
            ),
            BottomNavBar(
              currentIndex: 0,
              onTap: (index) => _handleNavigation(context, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final String logo;
  final String name;

  const _CouponCard({
    required this.logo,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.network(
            logo,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle redeem action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31E24),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Redeem Coins',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
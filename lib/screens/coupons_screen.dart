import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velitt/services/wallet_service.dart';
import 'package:velitt/state/member_state.dart';
import 'package:velitt/screens/coins_screen.dart';
import 'package:velitt/services/coupon_service.dart';
import 'package:logging/logging.dart';
import 'package:velitt/widgets/bottom_navbar.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  double _balance = 0;
  bool _isLoading = true;
  List<dynamic> _coupons = [];
  String _errorMessage = '';

  final Logger _logger = Logger('CouponsScreen');

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
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
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    try {
      final coupons = await CouponApiService.fetchCoupons();
      setState(() {
        _coupons = coupons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load coupons: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateToRedemption(int couponId, String type) {
    final memberState = Provider.of<MemberState>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoinRedemptionScreen(
          couponId: couponId,
          couponType: type,
          balance: _balance,
          onRedeem: (coins) async {
            try {
              _logger.info('Redeeming $coins coins for coupon $couponId');
              final response = await CouponApiService.redeemCoupon(
                memberId: int.tryParse(memberState.memberId ?? '') ?? 0,
                couponId: couponId,
                redeemType: type,
                additionalData: {'coins': coins},
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response['message'])),
                );
                // Refresh wallet balance after redemption
                memberState.updateMember(
                  id: response['user_id'].toString(),
                  email: response['email'],
                  name: response['username'],
                  image: response['profile_picture'],
                  coins: double.parse(response['coins']),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberState = Provider.of<MemberState>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Balance Section
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
                  // Centered Row for Coins and Mascot
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Center the row
                      children: [
                        Image.asset(
                          'assets/images/coin_green.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${memberState.memberCoins}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/mascot.png',
                          width: 60,
                          height: 60,
                        ),
                      ],
                    ),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: _coupons.map((coupon) {
                            return _CouponCard(
                              logo: 'assets/images/coupons/${coupon['picture']}',
                              name: coupon['name'],
                              onRedeem: () => _navigateToRedemption(
                                int.parse(coupon['id']),
                                coupon['type'],
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) => _handleNavigation(context, index),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final String logo;
  final String name;
  final VoidCallback onRedeem;

  const _CouponCard({
    required this.logo,
    required this.name,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset(
            logo,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRedeem,
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
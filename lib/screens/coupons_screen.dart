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
      final coupons = await CouponApiService.fetchAllCoupons();
      if (coupons == null || coupons.isEmpty) {
        // When API returns empty data, show a friendly message.
        setState(() {
          _errorMessage = 'No coupons available at the moment.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _coupons = coupons;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // Show a user-friendly error message.
        _errorMessage = 'Failed to load coupons. Please try again later.';
        _isLoading = false;
      });
      _logger.severe('Error fetching coupons', e);
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
                memberId: memberState.memberId,
                couponId: couponId,
                redeemType: type,
                additionalData: {'coins': coins},
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response['message'] ?? 'Coupon redeemed successfully.',
                    ),
                  ),
                );
                // Refresh wallet balance after redemption.
                memberState.updateMember(
                  id: response['user_id'],
                  email: response['email'],
                  name: response['username'],
                  image: response['profile_picture'],
                  coins: double.parse(response['coins']),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Failed to redeem coupon. Please try again later.'),
                  ),
                );
              }
              _logger.severe('Error redeeming coupon', e);
            }
          },
        ),
      ),
    );
  }

  /// Determines which redemption flow to use based on the coupon type.
  void _handleCouponRedeem(Map<String, dynamic> coupon) {
    // If coupon type is "Coins", navigate to the coin redemption screen.
    if (coupon['type'].toString().toLowerCase() == 'coins') {
      int couponId = int.tryParse(coupon['id'].toString()) ?? 0;
      _navigateToRedemption(couponId, coupon['type']);
    } else {
      _showCouponRedeemDialog(coupon);
    }
  }

  /// Shows a popup dialog for coupons that require additional input.
  ///
  /// After the input is taken and the coupon is successfully redeemed,
  /// the entire screen is replaced by the CoinRedemptionScreen.
  void _showCouponRedeemDialog(Map<String, dynamic> coupon) {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accountNumberController = TextEditingController();
    final TextEditingController accountNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController giftCardNumberController = TextEditingController();
    final TextEditingController giftCardPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Redeem ${coupon['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (coupon['type'] == 'Phone Number')
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                if (coupon['type'] == 'Bank')
                  Column(
                    children: [
                      TextField(
                        controller: bankNameController,
                        decoration: const InputDecoration(labelText: 'Bank Name'),
                      ),
                      TextField(
                        controller: accountNumberController,
                        decoration: const InputDecoration(labelText: 'Account Number'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: accountNameController,
                        decoration: const InputDecoration(labelText: 'Account Name'),
                      ),
                    ],
                  ),
                if (coupon['type'] == 'Email')
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                if (coupon['type'] == 'Gift Card')
                  Column(
                    children: [
                      TextField(
                        controller: giftCardNumberController,
                        decoration: const InputDecoration(labelText: 'Gift Card Number'),
                      ),
                      TextField(
                        controller: giftCardPinController,
                        decoration: const InputDecoration(labelText: 'Gift Card PIN'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final Map<String, dynamic> additionalData = {};

                switch (coupon['type']) {
                  case 'Phone Number':
                    additionalData['phone'] = phoneController.text;
                    break;
                  case 'Bank':
                    additionalData['bank_name'] = bankNameController.text;
                    additionalData['account_number'] = accountNumberController.text;
                    additionalData['account_name'] = accountNameController.text;
                    break;
                  case 'Email':
                    additionalData['email'] = emailController.text;
                    break;
                  case 'Gift Card':
                    additionalData['gift_card_number'] = giftCardNumberController.text;
                    additionalData['gift_card_pin'] = giftCardPinController.text;
                    break;
                }

                try {
                  final memberState =
                      Provider.of<MemberState>(context, listen: false);
                  // Determine redeemType.
                  String redeemType;
                  switch (coupon['type'].toString().toLowerCase()) {
                    case 'phone number':
                      redeemType = 'phone';
                      break;
                    case 'bank':
                      redeemType = 'bank';
                      break;
                    case 'email':
                      redeemType = 'email';
                      break;
                    case 'gift card':
                      redeemType = 'gift-card';
                      break;
                    default:
                      redeemType = 'coins';
                      break;
                  }
                  final int couponId =
                      int.tryParse(coupon['id'].toString()) ?? 0;
                  final response = await CouponApiService.redeemCoupon(
                    memberId: memberState.memberId,
                    couponId: couponId,
                    redeemType: redeemType,
                    additionalData: additionalData,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response['message'] ??
                              'Coupon redeemed successfully.',
                        ),
                      ),
                    );
                    // After successful redemption, replace the CouponsScreen
                    // with the CoinRedemptionScreen.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoinRedemptionScreen(
                          couponId: couponId,
                          couponType: coupon['type'],
                          balance: memberState.memberCoins,
                          onRedeem: (coins) async {
                            try {
                              _logger.info(
                                  'Redeeming $coins coins for coupon $couponId');
                              final resp = await CouponApiService.redeemCoupon(
                                memberId: memberState.memberId,
                                couponId: couponId,
                                redeemType: coupon['type'],
                                additionalData: {'coins': coins},
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      resp['message'] ??
                                          'Coupon redeemed successfully.',
                                    ),
                                  ),
                                );
                                memberState.updateMember(
                                  id: resp['user_id'],
                                  email: resp['email'],
                                  name: resp['username'],
                                  image: resp['profile_picture'],
                                  coins: double.parse(resp['coins']),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to redeem coupon. Please try again later.'),
                                  ),
                                );
                              }
                              _logger.severe('Error redeeming coupon', e);
                            }
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Failed to redeem coupon. Please try again later.'),
                      ),
                    );
                  }
                  _logger.severe('Error redeeming coupon', e);
                }
              },
              child: const Text('Request'),
            ),
          ],
        );
      },
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
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                            // Convert coupon to a Map<String, dynamic>
                            final couponMap =
                                Map<String, dynamic>.from(coupon);
                            return _CouponCard(
                              logo:
                                  'assets/images/coupons/${couponMap['picture']}',
                              name: couponMap['name'],
                              onRedeem: () => _handleCouponRedeem(couponMap),
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

/// Private widget for coupon cards.
class _CouponCard extends StatelessWidget {
  final String logo;
  final String name;
  final VoidCallback onRedeem;

  const _CouponCard({
    super.key,
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
              'Request Coupon',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velitt/state/member_state.dart';
import 'package:velitt/widgets/wallet_header.dart';
import 'package:flutter/services.dart';
import 'package:velitt/services/coupon_service.dart';
import 'package:velitt/services/wallet_service.dart';
import 'package:velitt/widgets/header.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:logging/logging.dart';

class CoinRedemptionScreen extends StatefulWidget {
  final int couponId;
  final String couponType;
  final double balance;
  final Function(double) onRedeem;

  const CoinRedemptionScreen({
    super.key,
    required this.couponId,
    required this.couponType,
    required this.balance,
    required this.onRedeem,
  });

  @override
  State<CoinRedemptionScreen> createState() => _CoinRedemptionScreenState();
}

class _CoinRedemptionScreenState extends State<CoinRedemptionScreen> {
  final List<double> predefinedCoins = [3, 10, 20, 40, 60, 80, 100, 150];
  final TextEditingController _customCoinsController = TextEditingController();
  final Logger _logger = Logger('CoinRedemptionScreen');

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/coupons');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Future<void> _updateBalance(double redeemedCoins) async {
    final memberState = Provider.of<MemberState>(context, listen: false);
    try {
      double newBalance = memberState.memberCoins - redeemedCoins;
      final response = await WalletApiService.updateBalance(memberState.memberId, newBalance);
      memberState.updateCoins(
        newBalance,
      );
      _logger.info('Member coins updated to ${newBalance}');
    } catch (e) {
      _logger.severe('Error updating balance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update wallet balance.')),
      );
    }
  }

  Future<void> _showCongratulations(double redeemedCoins) async {
    await _updateBalance(redeemedCoins);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Image.asset('assets/images/congratulations.png'),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _showRedeemModal(BuildContext context, double coins) {
    _customCoinsController.clear();
    final memberState = Provider.of<MemberState>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: _customCoinsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter number of coins',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_customCoinsController.text.isNotEmpty) {
                        double inputCoins = double.tryParse(_customCoinsController.text) ?? 0;
                        if (inputCoins <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                              showCloseIcon: true,
                            ),
                          );
                        } else if (inputCoins > memberState.memberCoins) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Insufficient balance'),
                              showCloseIcon: true,
                            ),
                          );
                        } else {
                          _showCongratulations(inputCoins);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter an amount'),
                            showCloseIcon: true,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31E24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Redeem',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCouponCard(double coins) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/mascot.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(width: 12),
                Text(
                  '$coins Fitties',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showRedeemModal(context, coins),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31E24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Redeem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memberState = Provider.of<MemberState>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            WalletHeaderWidget(
              coins: memberState.memberCoins,
              showRedeemButton: false,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customCoinsController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Number of coins',
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_customCoinsController.text.isNotEmpty) {
                          double coins = double.tryParse(_customCoinsController.text) ?? 0;
                          if (coins <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount'),
                              ),
                            );
                          } else if (coins > memberState.memberCoins) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Insufficient balance'),
                              ),
                            );
                          } else {
                            _showCongratulations(coins);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter an amount'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31E24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Redeem Coins',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: predefinedCoins.length,
                itemBuilder: (context, index) =>
                    _buildCouponCard(predefinedCoins[index]),
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
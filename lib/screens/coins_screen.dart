import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:velitt/services/coupon_service.dart';
import 'package:velitt/services/wallet_service.dart';
import 'package:velitt/widgets/header.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:velitt/state/member_state.dart';
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
  // Use doubles for predefined coins so that if needed you can have fractional amounts.
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

  /// Calls the update balance endpoint and updates the MemberState.
  Future<void> _updateBalance(double redeemedCoins) async {
    final memberState = Provider.of<MemberState>(context, listen: false);
    try {
      // Calculate the new balance.
      double newBalance = memberState.memberCoins - redeemedCoins;
      // Call your update endpoint.
      final response = await WalletApiService.updateBalance(memberState.memberId, newBalance);
      // Update local MemberState. Adjust the keys based on your response.
      memberState.updateCoins(
        newBalance,
      );
      _logger.info('Member coins updated to ${newBalance}');
    } catch (e) {
      _logger.severe('Error updating balance: $e');
      // Optionally show a snackbar if needed:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update wallet balance.')),
      );
    }
  }

  /// Shows a modal dialog with a congratulatory image, updates the wallet balance, then dismisses the screen.
  Future<void> _showCongratulations(double redeemedCoins) async {
    // First update the member coins on the backend.
    await _updateBalance(redeemedCoins);

    // Show the congratulatory image.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Image.asset('assets/images/congratulations.png'),
      ),
    );
    // Display the image for 2 seconds.
    await Future.delayed(const Duration(seconds: 2));
    // Close the congratulations dialog.
    Navigator.of(context).pop();
    // Quit the redemption screen.
    Navigator.of(context).pop();
  }

  /// Opens a modal dialog for predefined coupon cards.
  /// (This modal allows further custom entry if needed.)
  void _showRedeemModal(BuildContext context, double coins) {
    // Clear any previous text before opening the dialog.
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
                  // Change the number color here (e.g., to white)
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
                          // Successful redemption using custom input.
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

  /// Builds a coupon card that shows a predefined coin amount.
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
    final MemberState memberState = Provider.of<MemberState>(context, listen: false);
    // Filter available predefined coins by comparing them to the member's coin balance.
    final List<double> availableCoins = predefinedCoins
        .where((coin) => coin <= memberState.memberCoins)
        .toList();
    _logger.info('Available coins: ${memberState.memberCoins}');

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
            // Custom Amount Input
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
                    // Change the number color here (for example, to white)
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
                      // Custom input redemption is immediate.
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
                            // Pass the redeemed coins to _showCongratulations.
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
            // Predefined Amounts List
            Expanded(
              child: ListView.builder(
                itemCount: availableCoins.length,
                itemBuilder: (context, index) =>
                    _buildCouponCard(availableCoins[index]),
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

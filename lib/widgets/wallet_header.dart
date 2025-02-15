import 'package:flutter/material.dart';

class WalletHeaderWidget extends StatelessWidget {
  final double coins;
  final VoidCallback? onRedeemPressed;
  final bool showRedeemButton;

  const WalletHeaderWidget({
    Key? key,
    required this.coins,
    this.onRedeemPressed,
    this.showRedeemButton = true,
  }) : super(key: key);

  double _calculateANGValue(double coins) {
    return coins * 1.39;
  }

  @override
  Widget build(BuildContext context) {
    final angValue = _calculateANGValue(coins);
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/velitt-logo.png',
                height: 30,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              const Text(
                'Balance',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/coin_green.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$coins',
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
              const SizedBox(height: 8),
              Text(
                'ANG ${angValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
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
              if (showRedeemButton) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRedeemPressed,
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
            ],
          ),
        ],
      ),
    );
  }
}

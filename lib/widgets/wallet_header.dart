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
    final Color redeemColor = coins >= 3 ? Colors.green : Colors.red;
    final String redeemStatus = coins >= 3 ? 'Ready to redeem' : 'Insufficient Balance';
    final String redeemImagePath = coins >= 3 ? 'assets/images/coin_green.png' : 'assets/images/coin_red.png';

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
                    redeemImagePath,
                    width: 64,
                    height: 64,
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
                    width: 64,
                    height: 64,
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

              Text(
                redeemStatus,
                style: TextStyle(
                  color: redeemColor,
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

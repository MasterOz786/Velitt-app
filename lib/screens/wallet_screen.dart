import 'package:flutter/material.dart';
import 'package:velitt/widgets/bottom_navbar.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/coupons');
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
            ),
            // Wallet History
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            'Wallet History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              // Handle Excel download
                            },
                            icon: const Icon(Icons.file_download),
                            label: const Text('Download Excel'),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              // Handle filter selection
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'today',
                                child: Text('Today'),
                              ),
                              const PopupMenuItem(
                                value: 'week',
                                child: Text('This Week'),
                              ),
                              const PopupMenuItem(
                                value: 'month',
                                child: Text('This Month'),
                              ),
                            ],
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Filter By Date',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.grey[200],
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Number of Coins',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Time',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Event',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: const [
                          _TransactionItem(
                            coins: '798',
                            date: '1/15/12',
                            time: '07:38 am',
                            event: 'Barone LLC.',
                          ),
                          _TransactionItem(
                            coins: '130',
                            date: '6/19/14',
                            time: '07:13 pm',
                            event: 'Acme Co.',
                          ),
                          _TransactionItem(
                            coins: '922',
                            date: '5/19/12',
                            time: '02:30 pm',
                            event: 'Abstergo Ltd.',
                          ),
                          _TransactionItem(
                            coins: '177',
                            date: '9/4/12',
                            time: '01:09 am',
                            event: 'Binford Ltd.',
                          ),
                          _TransactionItem(
                            coins: '556',
                            date: '7/11/19',
                            time: '01:08 pm',
                            event: 'Biffco Ent.',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.navigate_before),
                            onPressed: () {},
                          ),
                          _PageNumber(number: '1', isActive: true),
                          _PageNumber(number: '2'),
                          _PageNumber(number: '3'),
                          _PageNumber(number: '4'),
                          _PageNumber(number: '5'),
                          IconButton(
                            icon: const Icon(Icons.navigate_next),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

class _TransactionItem extends StatelessWidget {
  final String coins;
  final String date;
  final String time;
  final String event;

  const _TransactionItem({
    required this.coins,
    required this.date,
    required this.time,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(coins),
          ),
          Expanded(
            flex: 2,
            child: Text(date),
          ),
          Expanded(
            flex: 2,
            child: Text(time),
          ),
          Expanded(
            flex: 2,
            child: Text(event),
          ),
        ],
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final String number;
  final bool isActive;

  const _PageNumber({
    required this.number,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE31E24) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velitt/state/member_state.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:velitt/widgets/wallet_header.dart';
import 'package:velitt/services/wallet_service.dart';
import 'package:logging/logging.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<dynamic> _transactions = [];
  // List<dynamic> _redemptions = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  final Logger _logger = Logger('WalletScreen');
  late MemberState memberState;

  @override
  void initState() {
    super.initState();
    memberState = Provider.of<MemberState>(context, listen: false);
    _fetchWalletData(memberState.memberId);
  }

  Future<void> _fetchWalletData(int memberId) async {
    try {
      final historyResponse = await WalletApiService.fetchHistory(memberId);
      // final redemptionsResponse = await WalletApiService.fetchRedemptions(memberId);

      setState(() {
        _transactions = historyResponse['transactions'];
        // _redemptions = redemptionsResponse['redemptions'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load wallet data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleNavigation(int index) {
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

  void _downloadExcel() {
    // Implement Excel download functionality
  }

  void _filterByDate(String period) {
    // Implement date filtering
  }

  @override
  Widget build(BuildContext context) {
    final MemberState memberState = Provider.of<MemberState>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            WalletHeaderWidget(
              coins: memberState.memberCoins,
              onRedeemPressed: () {
                Navigator.pushNamed(context, '/coupons');
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE31E24), Colors.black],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wallet History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _downloadExcel,
                        icon: const Icon(Icons.file_download, color: Colors.white, size: 20),
                        label: const Text(
                          'Download Excel',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PopupMenuButton<String>(
                          onSelected: _filterByDate,
                          child: Row(
                            children: [
                              Text(
                                'Filter By Date',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.black87),
                            ],
                          ),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Number of Coins',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Date',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Time',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Event',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = _transactions[index];
                                  return _TransactionItem(
                                    coins: transaction['coins'].toString(),
                                    date: transaction['date'],
                                    time: transaction['time'],
                                    event: transaction['event'],
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    color: Colors.grey,
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  for (int i = 1; i <= _transactions.length / _itemsPerPage; i++)
                                    _buildPageButton(i),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    color: Colors.grey,
                                    onPressed: _currentPage < 5
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isCurrentPage ? const Color(0xFFE31E24) : Colors.grey,
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              coins,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              event,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
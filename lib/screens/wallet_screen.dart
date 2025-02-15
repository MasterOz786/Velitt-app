import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:velitt/state/member_state.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:velitt/widgets/wallet_header.dart';
import 'package:velitt/services/wallet_service.dart';
import 'package:logging/logging.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<dynamic> _transactions = [];
  List<dynamic> _redemptions = [];
  List<dynamic> _allTransactions = [];
  List<dynamic> _allRedemptions = [];

  bool _isLoading = true;
  String _errorMessage = '';

  int _currentPage = 1;
  final int _itemsPerPage = 5;

  int _currentRedemptionPage = 1;
  final int _redemptionItemsPerPage = 5;

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
      final redemptionsResponse =
          await WalletApiService.fetchRedemptions(memberId);

      setState(() {
        _transactions = historyResponse['transactions'];
        _allTransactions = List.from(_transactions);

        _redemptions = redemptionsResponse['redemptions'];
        _allRedemptions = List.from(_redemptions);

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

  Future<void> _downloadExcel() async {
    var excel = Excel.createExcel();
    var sheet = excel['Wallet History'];

    // Shashkay
    CellStyle headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString("#1AFF1A"),
      fontFamily: getFontFamily(FontFamily.Calibri)
    );
    headerStyle.underline = Underline.Single;

    // Add headers
    // Set header row values in row 1
      var cellA1 = sheet.cell(CellIndex.indexByString("A1"));
      cellA1.value = TextCellValue("Number of Coins");
      cellA1.cellStyle = headerStyle;

      var cellB1 = sheet.cell(CellIndex.indexByString("B1"));
      cellB1.value = TextCellValue("Date & Time");
      cellB1.cellStyle = headerStyle;

      var cellC1 = sheet.cell(CellIndex.indexByString("C1"));
      cellC1.value = TextCellValue("Event");
      cellC1.cellStyle = headerStyle;

    // Add data
    for (var transaction in _allTransactions) {
      sheet.appendRow([
        TextCellValue(transaction['coins'].toString()),
        TextCellValue('${transaction['date']} ${transaction['time']}'),
        TextCellValue(transaction['event'])
      ]);
    }

    // Generate excel file
    var fileBytes = excel.save();
    
    // Get the documents directory
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/wallet_history.xlsx');
    
    // Write the file
    await file.writeAsBytes(fileBytes!);

    // Show a snackbar to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file saved to ${file.path}')),
    );
  }

  void _filterByDate(String period) {
    setState(() {
      final now = DateTime.now();
      _transactions = _allTransactions.where((transaction) {
        final transactionDate = DateTime.parse(transaction['date']);
        switch (period) {
          case 'today':
            return transactionDate.year == now.year &&
                transactionDate.month == now.month &&
                transactionDate.day == now.day;
          case 'week':
            final weekAgo = now.subtract(const Duration(days: 7));
            return transactionDate.isAfter(weekAgo);
          case 'month':
            return transactionDate.year == now.year &&
                transactionDate.month == now.month;
          default:
            return true;
        }
      }).toList();
      _currentPage = 1;
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      if (status == 'all') {
        _redemptions = List.from(_allRedemptions);
      } else {
        _redemptions = _allRedemptions.where((r) {
          final rStatus = (r['status'] as String).toLowerCase();
          return rStatus == status.toLowerCase();
        }).toList();
      }
      _currentRedemptionPage = 1;
    });
  }

  Widget _buildPagination({
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.grey,
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
        ),
        for (int i = 1; i <= totalPages; i++)
          GestureDetector(
            onTap: () => onPageChanged(i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor:
                    i == currentPage ? const Color(0xFFE31E24) : Colors.grey,
                child: Text(
                  i.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        i == currentPage ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: Colors.grey,
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final MemberState memberState = Provider.of<MemberState>(context);

    final totalPagesTransactions =
        (_transactions.length / _itemsPerPage).ceil();
    final startIndexTrans = (_currentPage - 1) * _itemsPerPage;
    final endIndexTrans =
        min(startIndexTrans + _itemsPerPage, _transactions.length);
    final displayedTransactions =
        _transactions.sublist(startIndexTrans, endIndexTrans);

    final totalPagesRedemptions =
        (_redemptions.length / _redemptionItemsPerPage).ceil();
    final startIndexRed =
        (_currentRedemptionPage - 1) * _redemptionItemsPerPage;
    final endIndexRed =
        min(startIndexRed + _redemptionItemsPerPage, _redemptions.length);
    final displayedRedemptions =
        _redemptions.sublist(startIndexRed, endIndexRed);

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
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                          icon: const Icon(
                                            Icons.file_download,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          label: const Text(
                                            'Excel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: PopupMenuButton<String>(
                                            onSelected: _filterByDate,
                                            child: Row(
                                              children: const [
                                                Text(
                                                  'Filter',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Icon(Icons.arrow_drop_down,
                                                    color: Colors.black87),
                                              ],
                                            ),
                                            itemBuilder: (context) => const [
                                              PopupMenuItem(
                                                value: 'today',
                                                child: Text('Today'),
                                              ),
                                              PopupMenuItem(
                                                value: 'week',
                                                child: Text('This Week'),
                                              ),
                                              PopupMenuItem(
                                                value: 'month',
                                                child: Text('This Month'),
                                              ),
                                              PopupMenuItem(
                                                value: 'all',
                                                child: Text('All'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                child: Row(
                                  children: const [
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
                                        'Date & Time',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
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
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: displayedTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction =
                                      displayedTransactions[index];
                                  return _TransactionItem(
                                    coins: transaction['coins'].toString(),
                                    date: transaction['date'],
                                    time: transaction['time'],
                                    event: transaction['event'],
                                  );
                                },
                              ),
                              if (totalPagesTransactions > 1)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: _buildPagination(
                                    currentPage: _currentPage,
                                    totalPages: totalPagesTransactions,
                                    onPageChanged: (page) {
                                      setState(() {
                                        _currentPage = page;
                                      });
                                    },
                                  ),
                                ),

                              const SizedBox(height: 24),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFE31E24), Colors.black],
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Redeem History',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: PopupMenuButton<String>(
                                        onSelected: _filterByStatus,
                                        child: Row(
                                          children: const [
                                            Text(
                                              'Filter',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black87,
                                            ),
                                          ],
                                        ),
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'all',
                                            child: Text('All'),
                                          ),
                                          PopupMenuItem(
                                            value: 'pending',
                                            child: Text('Pending'),
                                          ),
                                          PopupMenuItem(
                                            value: 'approved',
                                            child: Text('Approved'),
                                          ),
                                          PopupMenuItem(
                                            value: 'rejected',
                                            child: Text('Rejected'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Redeemer',
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
                                        'Coupon',
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
                                        'Date & Time',
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
                                        'Status',
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

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: displayedRedemptions.length,
                                itemBuilder: (context, index) {
                                  final redemption =
                                      displayedRedemptions[index];
                                  return _RedemptionItem(
                                    member_name: redemption['name'],
                                    coupon_name: redemption['coupon'],
                                    date: redemption['date'] +
                                        ' ' +
                                        redemption['time'],
                                    status: redemption['status'],
                                  );
                                },
                              ),
                              if (totalPagesRedemptions > 1)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: _buildPagination(
                                    currentPage: _currentRedemptionPage,
                                    totalPages: totalPagesRedemptions,
                                    onPageChanged: (page) {
                                      setState(() {
                                        _currentRedemptionPage = page;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
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
    // Concatenate date and time
    final String dateTime = '$date $time';

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
              dateTime,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
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

class _RedemptionItem extends StatelessWidget {
  final String member_name;
  final String coupon_name;
  final String date;
  final String status;

  const _RedemptionItem({
    required this.member_name,
    required this.coupon_name,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.purple;
        break;
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.black87;
    }

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
              member_name,
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
              coupon_name,
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
              status,
              style: TextStyle(
                fontSize: 14,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

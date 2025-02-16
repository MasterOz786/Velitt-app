import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velitt/state/member_state.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:velitt/widgets/wallet_header.dart';
import 'package:velitt/services/wallet_service.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
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

  // We keep backup lists for filtering:
  List<dynamic> _allTransactions = [];
  List<dynamic> _allRedemptions = [];

  bool _isLoading = true;
  String _errorMessage = '';

  int _currentPage = 1;
  final int _itemsPerPage = 5;
  
  int _currentRedemptionPage = 1;
  final int _redemptionItemsPerPage = 5;

  // Logging
  final Logger _logger = Logger('WalletScreen');
  late MemberState memberState;

  @override
  void initState() {
    super.initState();
    memberState = Provider.of<MemberState>(context, listen: false);
    _fetchWalletData(memberState.memberId);
  }

  // ----------------------------------------------------------------
  // Fetch Data
  // ----------------------------------------------------------------
  Future<void> _fetchWalletData(int memberId) async {
    try {
      final historyResponse = await WalletApiService.fetchHistory(memberId);
      final redemptionsResponse =
          await WalletApiService.fetchRedemptions(memberId);

      setState(() {
        // Transactions
        _transactions = historyResponse['transactions'];
        _allTransactions = List.from(_transactions);

        // Redemptions
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

  // ----------------------------------------------------------------
  // Navigation
  // ----------------------------------------------------------------
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
      cellA1.value = TextCellValue("Event");
      cellA1.cellStyle = headerStyle;

      var cellB1 = sheet.cell(CellIndex.indexByString("B1"));
      cellB1.value = TextCellValue("Fitties Earnt");
      cellB1.cellStyle = headerStyle;

      var cellC1 = sheet.cell(CellIndex.indexByString("C1"));
      cellC1.value = TextCellValue("Date & Time");
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
      DateTime startDate;

      switch (period) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          _transactions = List.from(_allTransactions);
          return;
      }

      _transactions = _allTransactions.where((transaction) {
        final transactionDate = DateFormat('yyyy-MM-dd').parse(transaction['date']);
        return transactionDate.isAfter(startDate) || transactionDate.isAtSameMomentAs(startDate);
      }).toList();

      // Reset transaction pagination
      _currentPage = 1;
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      // "all" means show everything
      if (status == 'all') {
        _redemptions = List.from(_allRedemptions);
      } else {
        // Filter by exact match of status (case-insensitive)
        _redemptions = _allRedemptions.where((r) {
          final rStatus = (r['status'] as String).toLowerCase();
          return rStatus == status;
        }).toList();
      }
      // Reset redemption pagination
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
        Text(
          'Page $currentPage of $totalPages',
          style: const TextStyle(color: Colors.white),
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

    // Calculate pagination details for transactions
    final totalPagesTransactions =
        (_transactions.length / _itemsPerPage).ceil();
    final startIndexTrans = (_currentPage - 1) * _itemsPerPage;
    final endIndexTrans =
        min(startIndexTrans + _itemsPerPage, _transactions.length);
    final displayedTransactions =
        _transactions.sublist(startIndexTrans, endIndexTrans);

    // Calculate pagination details for redemptions
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
            // ---------------- Wallet Header ----------------
            WalletHeaderWidget(
              coins: memberState.memberCoins,
              onRedeemPressed: () {
                Navigator.pushNamed(context, '/coupons');
              },
            ),

            // ---------------- Wallet History header (with download and filter) ----------------
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
                              // ---------------- Wallet Transactions Section ----------------
                              if (_transactions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No transaction history available.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              else
                                Column(
                                  children: [
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
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
                                  ],
                                ),

                              const SizedBox(height: 24),

                              // ---------------- Redeem History Header (similar style) ----------------
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
                                // Add a row to hold the title + status filter
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
                                    // Status filter for redemptions
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20),
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

                              // ---------------- Redeem History Table Header ----------------
                              if (_redemptions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No redemption history available.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              else
                                Column(
                                  children: [
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

                                    // ---------------- Redeem History List ----------------
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: _buildPagination(
                                          currentPage:
                                              _currentRedemptionPage,
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

// ----------------------------------------------------------------
// Transaction List Item
// ----------------------------------------------------------------
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

// ----------------------------------------------------------------
// Redemption List Item
// ----------------------------------------------------------------
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


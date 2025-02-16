import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velitt/state/member_state.dart';
import 'package:velitt/widgets/wallet_header.dart';
import 'package:velitt/services/coupon_service.dart';
import 'package:velitt/widgets/bottom_navbar.dart';
import 'package:logging/logging.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velitt/screens/coins_screen.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  bool _isLoading = true;
  List<dynamic> _coupons = [];
  String _errorMessage = '';

  final Logger _logger = Logger('CouponsScreen');

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    try {
      final coupons = await CouponApiService.fetchAllCoupons();
      if (coupons.isEmpty) {
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
        _errorMessage = 'Failed to load coupons. Please try again later.';
        _isLoading = false;
      });
      _logger.severe('Error fetching coupons', e);
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
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Coupons'];

      CellStyle headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#1AFF1A'),
        fontFamily: getFontFamily(FontFamily.Calibri),
        bold: true,
      );

      // Set headers
      sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue("Coupon Name");
      sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue("Type");
      sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue("Value");

      // Apply header style
      ['A1', 'B1', 'C1'].forEach((cellIndex) {
        sheetObject.cell(CellIndex.indexByString(cellIndex)).cellStyle = headerStyle;
      });

      // Add coupon data
      for (int i = 0; i < _coupons.length; i++) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(_coupons[i]['name']);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(_coupons[i]['type']);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = TextCellValue(_coupons[i]['value'].toString());
      }

      final List<int>? fileBytes = excel.save();
      if (fileBytes == null) throw Exception("Excel encoding failed");

      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/coupons.xlsx';
      final File file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'Coupons Excel File');
    } catch (e) {
      _logger.severe('Error creating or sharing Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export Excel: $e')),
      );
    }
  }

  void _handleCouponRedeem(Map<String, dynamic> coupon) {
    if (coupon['type'].toString().toLowerCase() == 'coins') {
      int couponId = int.tryParse(coupon['id'].toString()) ?? 0;
      _navigateToCoinsScreen(couponId, coupon['type']);
    } else {
      _showCouponRedeemDialog(coupon);
    }
  }

  void _navigateToCoinsScreen(int couponId, String type) {
    final memberState = Provider.of<MemberState>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoinRedemptionScreen(
          couponId: couponId,
          couponType: type,
          balance: memberState.memberCoins,
          onRedeem: (coins) async {
            // The actual redemption will happen in the CoinRedemptionScreen
          },
        ),
      ),
    );
  }

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
              onPressed: () {
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

                Navigator.pop(context);
                _navigateToCoinsScreen(int.parse(coupon['id']), coupon['type']);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
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
              onRedeemPressed: () {
                Navigator.pushNamed(context, '/coupons');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Coupons',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download, color: Colors.white),
                    onPressed: _downloadExcel,
                    tooltip: 'Download Coupons Excel',
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
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: _coupons.map((coupon) {
                            final couponMap = Map<String, dynamic>.from(coupon);
                            return _CouponCard(
                              logo: 'assets/images/coupons/${couponMap['picture']}',
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
        onTap: _handleNavigation,
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final String logo;
  final String name;
  final VoidCallback onRedeem;

  const _CouponCard({
    Key? key,
    required this.logo,
    required this.name,
    required this.onRedeem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            logo,
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
              'Redeem Coupon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
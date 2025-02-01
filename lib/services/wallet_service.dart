import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class WalletApiService {
  static const String baseUrl = 'http://localhost/api/wallet.php';

  // Fetch wallet balance
  static Future<Map<String, dynamic>> fetchBalance(String memberId) async {
    final response = await http.get(Uri.parse('$baseUrl/balance?member_id=$memberId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch balance');
    }
  }

  // Fetch wallet history
  static Future<Map<String, dynamic>> fetchHistory(String memberId) async {
    final response = await http.get(Uri.parse('$baseUrl/history?member_id=$memberId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch history');
    }
  }

  // Redeem coins
  static Future<Map<String, dynamic>> redeemCoins(int memberId, int couponId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/redeem'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'member_id': memberId, 'coupon_id': couponId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to redeem coins');
    }
  }
}
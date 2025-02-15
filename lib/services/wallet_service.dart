import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletApiService {
  static const String baseUrl = 'https://velitt.digital/api/wallet.php';
  static const String membersUrl = 'https://velitt.digital/api/members.php';

  // Fetch wallet balance
  static Future<Map<String, dynamic>> fetchBalance(int memberId) async {
    final response = await http.get(Uri.parse('$baseUrl/balance?member_id=$memberId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch balance');
    }
  }

  // Fetch wallet history
  static Future<Map<String, dynamic>> fetchHistory(int memberId) async {
    final response = await http.get(Uri.parse('$baseUrl/history?member_id=$memberId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch history');
    }
  }

  // Fetch redemption history
  static Future<Map<String, dynamic>> fetchRedemptions(int memberId) async {
    final response = await http.get(Uri.parse('$baseUrl/redemptions?member_id=$memberId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch redemptions');
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

  // Update wallet balance
  static Future<Map<String, dynamic>> updateBalance(int memberId, double coins) async {
    final response = await http.put(
      Uri.parse('$membersUrl/updateCoins'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'member_id': memberId, 'coins': coins}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update balance');
    }
  }
}
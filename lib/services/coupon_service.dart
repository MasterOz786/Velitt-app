import 'dart:convert';
import 'package:http/http.dart' as http;

/// Custom exception that only returns a user-friendly message.
class CouponException implements Exception {
  final String message;
  CouponException(this.message);

  @override
  String toString() => message;
}

class CouponApiService {
  static const String baseUrl = 'http://localhost/api/coupons.php';

  // Fetch coupons for a specific user
  static Future<List<dynamic>> fetchCoupons(int memberId) async {
    // Put member id in the request body if needed (or adjust the endpoint)
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final coupons = json.decode(response.body);
      for (var i = 0; i < coupons.length; i++) {
        // Extract the filename from the path
        final String? path = coupons[i]['picture'];
        final String? filename = path?.split('/').last;
        coupons[i]['picture'] = filename;
      }
      return coupons;
    } else {
      // Throw a custom exception with a friendly message
      throw CouponException('Failed to fetch coupons. Please try again later.');
    }
  }

  // Fetch all coupons
  static Future<List<dynamic>> fetchAllCoupons() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final coupons = json.decode(response.body);
      for (var i = 0; i < coupons.length; i++) {
        final path = coupons[i]['picture'];
        final filename = path.split('/').last;
        coupons[i]['picture'] = filename;
      }
      return coupons;
    } else {
      throw CouponException('Failed to fetch coupons. Please try again later.');
    }
  }

  // Redeem a coupon
  static Future<Map<String, dynamic>> redeemCoupon({
    required int memberId,
    required int couponId,
    required String redeemType,
    Map<String, dynamic>? additionalData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/redeem'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'member_id': memberId,
        'coupon_id': couponId,
        ...(additionalData ?? {}),
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw CouponException('Failed to redeem coupon. Please try again later.');
    }
  }
}

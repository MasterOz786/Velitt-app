import 'dart:convert';
import 'package:http/http.dart' as http;

class CouponApiService {
  static const String baseUrl = 'http://localhost/api/coupons.php';

  // Fetch all coupons
  static Future<List<dynamic>> fetchCoupons() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final coupons = json.decode(response.body);
      for (var i = 0; i < coupons.length; i++) {
        // Extract the filename from the path
        final path = coupons[i]['picture'];
        final filename = path.split('/').last; // Get the last part after the last slash
        coupons[i]['picture'] = filename; // Update the picture field with the filename
      }
      return coupons;
    } else {
      throw Exception('Failed to fetch coupons');
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
      Uri.parse('$baseUrl/redeem/$redeemType'),
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
      throw Exception('Failed to redeem coupon');
    }
  }
}
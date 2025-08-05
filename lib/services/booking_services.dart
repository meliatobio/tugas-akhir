// lib/features/booking/services/booking_service.dart

import 'dart:convert';
import 'package:bengkel/constants/api_base.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/booking_model.dart';

class BookingService {
  static Future<List<BookingModel>> fetchUserBookings() async {
    final token = await GetStorage().read('token');
    final response = await http.get(
      Uri.parse('${ApiBase.baseUrl}bookings'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((item) => BookingModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data booking');
    }
  }
}

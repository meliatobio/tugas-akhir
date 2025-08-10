import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/booking_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class BookingService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiBase.baseUrl));

  // Booking untuk USER (Customer)
  static Future<int?> getUserIdFromToken(String? token) async {
    if (token == null || token.isEmpty) return null;

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      // Contoh key user id biasanya 'sub', 'user_id', atau sesuai payload token backend kamu
      if (decodedToken.containsKey('user_id')) {
        return decodedToken['user_id'];
      } else if (decodedToken.containsKey('sub')) {
        return int.tryParse(decodedToken['sub'].toString());
      }
    } catch (e) {
      debugPrint('Error decoding token: $e');
    }
    return null;
  }

  static Future<List<BookingModel>> fetchUserBookings() async {
    final token = await GetStorage().read('token');
    final userId = await GetStorage().read('userId'); // Baca userId langsung
    debugPrint('Token: $token');
    debugPrint('UserId dari storage: $userId');

    final response = await http.get(
      Uri.parse('${ApiBase.baseUrl}bookings'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      debugPrint('Raw booking data count: ${jsonData.length}');

      if (userId != null) {
        final filteredData = jsonData.where((item) {
          debugPrint('Checking item user_id: ${item['user_id']}');
          return item['user_id'].toString() == userId.toString();
        }).toList();
        debugPrint('Filtered data count: ${filteredData.length}');
        return filteredData.map((item) => BookingModel.fromJson(item)).toList();
      } else {
        return jsonData.map((item) => BookingModel.fromJson(item)).toList();
      }
    } else {
      throw Exception('Gagal memuat data booking');
    }
  }
}


   // Booking untuk OWNER (Pemilik Bengkel)
  //  Future<List<BookingModel>> fetchOwnerBookings(String token, int storeId) async {
  //   try {
  //     final response = await _dio.get(
  //       '/store/$storeId/booking',
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.data['data'];

  //       if (data != null && data is List) {
  //         return data.map<BookingModel>((e) => BookingModel.fromJson(e)).toList();
  //       } else {
  //         return [];
  //       }
  //     } else {
  //       throw Exception('Gagal memuat data booking untuk owner, status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching owner bookings: $e');
  //     throw Exception('Error fetching owner bookings: $e');
  //   }
  //}

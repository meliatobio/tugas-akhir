import 'dart:convert';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/booking_model.dart';
import 'package:bengkel/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class BookingService {
  /// Create booking
  static Future<bool> createBooking({
    required int storeId,
    required int serviceId,
    required String vehicleType,
    required String licensePlate,
    required String bookingTime,
    required String notes,
    required int totalPrice,
  }) async {
    try {
      final token = StorageService.token;
      final userId = StorageService.userId;

      if (token == null || userId == null) {
        debugPrint("❌ Token atau User ID tidak ditemukan di storage");
        return false;
      }

      final bookingData = {
        "user_id": userId,
        "store_id": storeId,
        "service_id": serviceId,
        "vehicle_type": vehicleType,
        "license_plate": licensePlate,
        "booking_time": bookingTime,
        "status": "pending",
        "notes": notes,
        "total_price": totalPrice,
        "payment_status": "unpaid",
        "payment_method": null,
      };

      debugPrint("📦 Booking Data yang dikirim: $bookingData");

      final response = await http.post(
        ApiBase.uri("booking"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(bookingData),
      );

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📡 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Booking berhasil");
        return true;
      } else {
        debugPrint("❌ Booking gagal");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error booking: $e");
      return false;
    }
  }

  static Future<List<BookingModel>> fetchUserBookings() async {
    final token = await GetStorage().read('token');
    final userId = await GetStorage().read('userId');
    debugPrint('Token: $token');
    debugPrint('UserId dari storage: $userId');

    final response = await http.get(
      ApiBase.uri("bookings"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // ambil array "data" kalau ada
      final List jsonData = decoded is Map && decoded.containsKey("data")
          ? decoded["data"]
          : decoded;

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

  /// Update booking status
  static Future<bool> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    try {
      final token = StorageService.token;
      if (token == null) return false;

      final response = await http.put(
        ApiBase.uri("store/bookings/$bookingId/status"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": status}),
      );

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📡 BODY: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Status booking berhasil diupdate");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Error update booking: $e");
      return false;
    }
  }
}

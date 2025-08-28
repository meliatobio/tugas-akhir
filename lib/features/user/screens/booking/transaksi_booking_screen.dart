import 'dart:convert';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TransaksiBookingScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  const TransaksiBookingScreen({super.key, required this.transaction});

  @override
  State<TransaksiBookingScreen> createState() => _TransaksiBookingScreenState();
}

class _TransaksiBookingScreenState extends State<TransaksiBookingScreen> {
  bool isSubmitting = false;

  DateTime? _safeBookingDateTime(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bookingDateTime = _safeBookingDateTime(
      widget.transaction['bookingDateTime'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Booking",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildItem(
                    "Jenis Kendaraan",
                    widget.transaction['jenisKendaraan']?.toString() ?? '-',
                  ),
                  _buildItem(
                    "Tanggal",
                    widget.transaction['tanggal']?.toString() ?? '-',
                  ),
                  _buildItem(
                    "Jam",
                    widget.transaction['jam']?.toString() ?? '-',
                  ),
                  _buildItem(
                    "No Polisi",
                    widget.transaction['noPol']?.toString() ?? '-',
                  ),
                  _buildItem(
                    "Layanan",
                    widget.transaction['layanan']?.toString() ?? '-',
                  ),
                  _buildItem(
                    "Catatan Tambahan",
                    widget.transaction['catatan']?.toString() ?? '-',
                  ),

                  _buildItem(
                    "Metode Pembayaran",
                    widget.transaction['paymentMethod']?.toString() ?? '-',
                  ),
                  // _buildItem(
                  //   "DP 30%",
                  //   widget.transaction['totalHarga'] != null
                  //       ? "Rp${(widget.transaction['totalHarga'] * 0.3).toStringAsFixed(0)}"
                  //       : "-",
                  // ),
                  _buildItem(
                    "Total Harga",
                    "Rp${widget.transaction['totalHarga'] ?? 0}",
                    valueColor: Colors.white, // semua teks putih
                    backgroundColor: Colors.green, // highlight box hijau
                    isBold: true, // semua teks bold
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (bookingDateTime == null || isSubmitting)
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        await _konfirmasiBooking(context, bookingDateTime);
                        if (mounted) setState(() => isSubmitting = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('KONFIRMASI'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    String label,
    String value, {
    Color? valueColor,
    Color? backgroundColor,
    bool isBold = false,
  }) {
    final textStyle = TextStyle(
      color: valueColor ?? Colors.black87,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: textStyle),
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiBooking(
    BuildContext context,
    DateTime bookingDateTime,
  ) async {
    final userId = StorageService.userId;
    final token = StorageService.token;
    final storeId = widget.transaction['storeId'];
    final serviceId = widget.transaction['serviceId'];
    final vehicleType = widget.transaction['jenisKendaraan'];
    final licensePlate = widget.transaction['noPol'];
    final totalHarga = widget.transaction['totalHarga'];
    final paymentMethod = widget.transaction['paymentMethod'] ?? 'cash';
    final notes = widget.transaction['catatan'] ?? '';

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User ID atau Token tidak tersedia. Silakan login ulang.',
          ),
        ),
      );
      return;
    }

    if (storeId == null || serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data booking tidak lengkap (storeId/serviceId).'),
        ),
      );
      return;
    }

    final String bookingTimeFormatted = bookingDateTime
        .toIso8601String()
        .replaceAll('T', ' ')
        .substring(0, 19);

    final body = {
      "user_id": userId,
      "store_id": storeId,
      "service_id": serviceId,
      "vehicle_type": (vehicleType ?? '').toString(),
      "license_plate": (licensePlate ?? '').toString(),
      "booking_time": bookingTimeFormatted,
      "status": "pending",
      "notes": (notes ?? '').toString(),
      "total_price": totalHarga ?? 0,
      "payment_status": "unpaid",
      "payment_method": paymentMethod.toString(),
    };

    try {
      final uri = Uri.parse('${ApiBase.baseUrl}booking');
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking berhasil')));
          Get.offAllNamed(Routers.dashboarduser, arguments: {'tab': 0});
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal booking: ${res.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }
}

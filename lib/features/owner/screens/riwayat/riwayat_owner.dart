import 'package:bengkel/models/booking_model.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class RiwayatOwnerScreen extends StatefulWidget {
  const RiwayatOwnerScreen({super.key});

  @override
  State<RiwayatOwnerScreen> createState() => _RiwayatOwnerScreenState();
}

class _RiwayatOwnerScreenState extends State<RiwayatOwnerScreen> {
  List<BookingModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red, size: 20);
      case 'pending':
        return const Icon(Icons.access_time, color: Colors.orange, size: 20);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 20);
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Booking",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? Center(
              child: Text(
                'Belum ada riwayat Booking.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final item = transactions[index];
                return GestureDetector(
                  onTap: () {
                    // Get.toNamed(
                    //   detailBookingowner,
                    //   arguments: item,
                    // );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(51),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.vehicleType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            getStatusIcon(item.status),
                            const SizedBox(width: 6),
                            Text(
                              'Status: ${item.status}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tanggal: ${formatDate(item.bookingTime)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Total: Rp${item.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

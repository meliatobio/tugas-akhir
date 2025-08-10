import 'package:bengkel/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailTransaksiScreen extends StatelessWidget {
  DetailTransaksiScreen({super.key});

  final BookingModel tx = Get.arguments as BookingModel;

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Transaksi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailItem("Status", tx.status),
            _buildDetailItem("Jenis Kendaraan", tx.vehicleType),
            _buildDetailItem("Tanggal", tx.bookingDate),
            _buildDetailItem("Jam", tx.bookingTime),
            _buildDetailItem("No Polisi", tx.licensePlate),
            _buildDetailItem("Layanan", tx.serviceName),
            _buildDetailItem("DP", formatCurrency(tx.dpAmount.toDouble())),
            _buildDetailItem("Total Harga", formatCurrency(tx.totalPrice)),
            const Divider(),
            _buildDetailItem("Rekening", tx.bankAccount),
            const SizedBox(height: 20),
            _buildUploadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Bukti Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // TODO: fungsi upload
          },
          child: const Text("Pilih Gambar"),
        ),
      ],
    );
  }
}

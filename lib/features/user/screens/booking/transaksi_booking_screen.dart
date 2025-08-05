import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransaksiBookingScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransaksiBookingScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaksi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); // Kembali ke InputBookingScreen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItem("Jenis Kendaraan", transaction['jenisKendaraan']),
            _buildItem("Tanggal", transaction['tanggal']),
            _buildItem("Jam", transaction['jam']),
            _buildItem("No Polisi", transaction['noPol']),
            _buildItem("Layanan", transaction['layanan']),
            _buildItem("Total Harga", "Rp${transaction['totalHarga']}"),
            _buildItem("DP", "Rp${transaction['dp']}"),
            _buildItem("Rekening", transaction['rekening']),
            _buildItem("Catatan Tambahan", transaction['catatan'] ?? '-'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman DetailBookingScreen
                  Get.toNamed('/detailbooking', arguments: transaction);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'KONFIRMASI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value?.toString() ?? '-', textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

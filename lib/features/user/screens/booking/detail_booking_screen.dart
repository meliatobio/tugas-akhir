import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

class DetailBookingScreen extends StatefulWidget {
  const DetailBookingScreen({super.key, required transaction});

  @override
  State<DetailBookingScreen> createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  String? _selectedImagePath;
  final data = Get.arguments;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImagePath = result.files.single.path;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Menunggu Konfirmasi';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Booking"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Get.offAllNamed('/dashboarduser');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItem("Status", status),
            _buildItem("Jenis Kendaraan", data['jenisKendaraan']),
            _buildItem("Tanggal", data['tanggal']),
            _buildItem("Jam", data['jam']),
            _buildItem("No Polisi", data['noPol']),
            _buildItem("Layanan", data['layanan']),
            _buildItem("Total Harga", "Rp${data['totalHarga']}"),
            _buildItem("DP", "Rp${data['dp']}"),
            _buildItem("Rekening", data['rekening']),
            _buildItem("Catatan", data['catatan']),
            const SizedBox(height: 20),
            const Text(
              "Upload Bukti Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (_selectedImagePath == null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Pilih File"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Image.file(
                    File(_selectedImagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "File berhasil dipilih",
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

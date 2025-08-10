import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailTransaksiScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const DetailTransaksiScreen({super.key, required this.transaction});

  @override
  State<DetailTransaksiScreen> createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedImagePath = prefs.getString(
        'uploadedImagePath_${widget.transaction['id']}',
      );
    });
  }

  Future<void> _saveImagePath(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'uploadedImagePath_${widget.transaction['id']}',
      filePath,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        return result.files.single.path;
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
    return null;
  }

  Widget _buildUploadSection() {
    final String status = widget.transaction['status'].toLowerCase();

    if (status == 'ditolak') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Transaksi ditolak. Upload tidak diperbolehkan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (_selectedImagePath == null)
            GestureDetector(
              onTap: () async {
                final filePath = await _pickFile();

                if (filePath != null) {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi Upload'),
                      content: const Text('Yakin upload gambar ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Ya'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    setState(() {
                      _selectedImagePath = filePath;
                    });
                    await _saveImagePath(filePath);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upload berhasil disimpan lokal'),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Icon(
                Icons.photo_camera,
                size: 40,
                color: Colors.grey,
              ),
            ),
          if (_selectedImagePath != null)
            Image.file(
              File(_selectedImagePath!),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem("Status", tx['status']),
            _buildDetailItem("Jenis Kendaraan", tx['jenisKendaraan']),
            _buildDetailItem("Tanggal", tx['tanggal']),
            _buildDetailItem("Jam", tx['jam'] ?? '-'),
            _buildDetailItem("No Polisi", tx['noPol'] ?? '-'),
            _buildDetailItem("Layanan", tx['layanan'] ?? '-'),
            _buildDetailItem("DP", "Rp${tx['dp'] ?? 0}"),
            _buildDetailItem("Total Harga", "Rp${tx['totalHarga']}"),
            const SizedBox(height: 10),
            const Divider(),
            _buildDetailItem("Rekening", tx['rekening'] ?? 'Belum tersedia'),
            const SizedBox(height: 20),
            _buildUploadSection(),
          ],
        ),
      ),
    );
  }
}

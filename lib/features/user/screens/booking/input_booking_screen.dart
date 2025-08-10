import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/services/storage_service.dart';

class InputBookingScreen extends StatefulWidget {
  const InputBookingScreen({super.key});

  @override
  State<InputBookingScreen> createState() => _InputBookingScreenState();
}

class _InputBookingScreenState extends State<InputBookingScreen> {
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Map<String, dynamic>? selectedLayanan;
  bool isLoading = false;

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking({
    required int storeId,
    required String vehicleType,
    required String licensePlate,
    required String serviceId,
  }) async {
    final token = StorageService.token;

    if (token == null) {
      Get.snackbar("Error", "Token tidak ditemukan.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final bookingDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final url = Uri.parse('${ApiBase.baseUrl}booking');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'store_id': storeId,
          'vehicle_type': vehicleType,
          'license_plate': licensePlate,
          'service_id': serviceId,
          'booking_datetime': bookingDateTime.toIso8601String(),
        }),
      );

      final responseData = jsonDecode(response.body);
      debugPrint('📦 Response: $responseData');

      if (response.statusCode == 201) {
        Get.snackbar("Berhasil", "Booking berhasil dilakukan.");
        Get.offAllNamed('/riwayattransaksi'); // atau kembali ke home/riwayat
      } else {
        Get.snackbar("Gagal", responseData['message'] ?? "Terjadi kesalahan.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final int? storeId = arguments['storeId'];
    final List<dynamic> layananList = arguments['layananList'] ?? [];

    final String totalHarga =
        selectedLayanan?['price']?.toStringAsFixed(0) ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _vehicleTypeController,
              decoration: const InputDecoration(labelText: 'Jenis Kendaraan'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _licensePlateController,
              decoration: const InputDecoration(labelText: 'Nomor Polisi'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tanggal'),
              subtitle: Text(
                selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(selectedDate!)
                    : 'Pilih tanggal',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Jam'),
              subtitle: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : 'Pilih jam',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(labelText: 'Pilih Layanan'),
              value: selectedLayanan,
              items: layananList.map((layanan) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: layanan,
                  child: Text(layanan['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLayanan = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp $totalHarga',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_vehicleTypeController.text.isEmpty ||
                          _licensePlateController.text.isEmpty ||
                          selectedDate == null ||
                          selectedTime == null ||
                          selectedLayanan == null ||
                          storeId == null) {
                        Get.snackbar('Error', 'Semua data harus diisi.');
                        return;
                      }

                      _submitBooking(
                        storeId: storeId,
                        vehicleType: _vehicleTypeController.text,
                        licensePlate: _licensePlateController.text,
                        serviceId: selectedLayanan!['id'].toString(),
                      );
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Konfirmasi'),
            ),
          ],
        ),
      ),
    );
  }
}

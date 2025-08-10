import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/owner/screens/dashboard/dashboard_owner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class TambahBengkelScreen extends StatefulWidget {
  const TambahBengkelScreen({super.key});

  @override
  State<TambahBengkelScreen> createState() => _TambahBengkelScreenState();
}

class _TambahBengkelScreenState extends State<TambahBengkelScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();
  final contactNameController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();
  final openAtController = TextEditingController();
  final closeAtController = TextEditingController();

  List<String> selectedVehicleTypes = [];
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    contactController.dispose();
    contactNameController.dispose();
    latController.dispose();
    longController.dispose();
    openAtController.dispose();
    closeAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Bengkel")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField("Nama Bengkel", nameController),
                  _buildTextField("Alamat Bengkel", addressController),
                  _buildTextField("Nomor Kontak", contactController),
                  _buildTextField(
                    "Nama Penanggung Jawab",
                    contactNameController,
                  ),
                  _buildTextField("Latitude", latController),
                  _buildTextField("Longitude", longController),
                  _buildTextField("Jam Buka (contoh: 08:00)", openAtController),
                  _buildTextField(
                    "Jam Tutup (contoh: 17:00)",
                    closeAtController,
                  ),

                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Jenis Kendaraan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CheckboxListTile(
                    value: selectedVehicleTypes.contains("motor"),
                    onChanged: (val) => _toggleVehicleType("motor"),
                    title: const Text("Motor"),
                  ),
                  CheckboxListTile(
                    value: selectedVehicleTypes.contains("car"),
                    onChanged: (val) => _toggleVehicleType("car"),
                    title: const Text("Mobil"),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Bengkel"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _toggleVehicleType(String type) {
    setState(() {
      if (selectedVehicleTypes.contains(type)) {
        selectedVehicleTypes.remove(type);
      } else {
        selectedVehicleTypes.add(type);
      }

      debugPrint("✅ selectedVehicleTypes updated: $selectedVehicleTypes");
    });
  }

  void _submit() async {
    debugPrint("🚀 SUBMIT DIJALANKAN");

    // Validasi kosong
    if (nameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty ||
        contactNameController.text.trim().isEmpty ||
        latController.text.trim().isEmpty ||
        longController.text.trim().isEmpty ||
        openAtController.text.trim().isEmpty ||
        closeAtController.text.trim().isEmpty ||
        selectedVehicleTypes.isEmpty) {
      Get.snackbar(
        "Error",
        "Harap lengkapi semua data termasuk jenis kendaraan.",
      );
      return;
    }

    final user = GetStorage().read('user');
    final token = GetStorage().read('token');

    if (user == null || token == null) {
      Get.snackbar("Error", "User tidak ditemukan atau belum login.");
      return;
    }

    final userId = user['id'];

    final data = {
      "user_id": userId,
      "store_name": nameController.text.trim(),
      "address": addressController.text.trim(),
      "contact": contactController.text.trim(),
      "contact_name": contactNameController.text.trim(),
      "lat": double.tryParse(latController.text.trim()),
      "long": double.tryParse(longController.text.trim()),
      "open_at": openAtController.text.trim().replaceAll(
        '.',
        ':',
      ), // format HH:mm
      "close_at": closeAtController.text.trim().replaceAll('.', ':'),
      "accepted_vehicle_types":
          selectedVehicleTypes, // contoh: ['motor', 'mobil']
    };

    debugPrint("📤 DATA YANG DIKIRIM: $data");

    setState(() => isLoading = true);

    try {
      final response = await Dio().post(
        ApiBase.uri('store/register').toString(),
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("✅ RESPONSE DARI BACKEND: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", "Bengkel berhasil ditambahkan");
        Get.back(result: 'refresh');
      } else {
        Get.snackbar(
          "Error",
          "Gagal menambahkan bengkel (${response.statusCode})",
        );
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", "Bengkel berhasil ditambahkan");

        // Navigasi ke DashboardOwnerScreen dan buka tab Home (index 0)
        Get.offAll(() => const DashboardOwnerScreen(), arguments: 0);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("❌ ERROR RESPONSE: ${e.response?.data}");
        Get.snackbar(
          "Error",
          e.response?.data['message'] ?? "Gagal mendaftarkan bengkel",
        );
      } else {
        debugPrint("❌ ERROR TANPA RESPONSE: ${e.message}");
        Get.snackbar("Error", "Tidak dapat menghubungi server");
      }
    } catch (e) {
      debugPrint("❌ ERROR TAK TERDUGA: $e");
      Get.snackbar("Error", "Terjadi kesalahan tidak terduga");
    } finally {
      setState(() => isLoading = false);
    }
  }
}

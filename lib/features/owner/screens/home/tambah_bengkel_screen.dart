import 'dart:io';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/owner/screens/dashboard/dashboard_owner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;

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
  XFile? pickedImage;
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Tambah Bengkel",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTextField(
                            "Nama Bengkel",
                            nameController,
                            icon: Icons.store,
                          ),
                          _buildTextField(
                            "Alamat Bengkel",
                            addressController,
                            icon: Icons.location_on,
                          ),
                          _buildTextField(
                            "Nomor Kontak",
                            contactController,
                            icon: Icons.phone,
                          ),
                          _buildTextField(
                            "Nama Penanggung Jawab",
                            contactNameController,
                            icon: Icons.person,
                          ),
                          _buildTextField(
                            "Latitude",
                            latController,
                            icon: Icons.map,
                          ),
                          _buildTextField(
                            "Longitude",
                            longController,
                            icon: Icons.map_outlined,
                          ),
                          _buildTextField(
                            "Jam Buka (contoh: 08:00)",
                            openAtController,
                            icon: Icons.access_time,
                          ),
                          _buildTextField(
                            "Jam Tutup (contoh: 17:00)",
                            closeAtController,
                            icon: Icons.access_time_filled,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Jenis Kendaraan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text("Motor"),
                        selected: selectedVehicleTypes.contains("motor"),
                        onSelected: (_) => _toggleVehicleType("motor"),
                        selectedColor: Colors.amber,
                      ),
                      ChoiceChip(
                        label: const Text("Mobil"),
                        selected: selectedVehicleTypes.contains("mobil"),
                        onSelected: (_) => _toggleVehicleType("mobil"),
                        selectedColor: Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (pickedImage != null)
                    Center(
                      child: Image.file(
                        File(pickedImage!.path),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Pilih Foto Bengkel"),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _submit,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "Simpan Bengkel",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.amber) : null,
          labelText: label,
          labelStyle: const TextStyle(fontFamily: "Poppins"),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.amber, width: 1.5),
          ),
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
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => pickedImage = image);
    }
  }

  Future<void> _submit() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        contactController.text.isEmpty ||
        contactNameController.text.isEmpty ||
        latController.text.isEmpty ||
        longController.text.isEmpty ||
        openAtController.text.isEmpty ||
        closeAtController.text.isEmpty ||
        selectedVehicleTypes.isEmpty) {
      Get.snackbar("Error", "Harap lengkapi semua data.");
      return;
    }

    if (pickedImage == null) {
      Get.snackbar("Error", "Foto bengkel wajib dipilih.");
      return;
    }

    final user = GetStorage().read('user');
    final token = GetStorage().read('token');

    if (user == null || token == null) {
      Get.snackbar("Error", "User tidak ditemukan atau belum login.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final formData = dio_pkg.FormData();

      final storeData = {
        "user_id": user['id'],
        "store_name": nameController.text.trim(),
        "address": addressController.text.trim(),
        "contact": contactController.text.trim(),
        "contact_name": contactNameController.text.trim(),
        "lat": double.tryParse(latController.text.trim()) ?? 0.0,
        "long": double.tryParse(longController.text.trim()) ?? 0.0,
        "open_at": openAtController.text.trim().replaceAll('.', ':'),
        "close_at": closeAtController.text.trim().replaceAll('.', ':'),
        "accepted_vehicle_types": selectedVehicleTypes,
      };

      // Tambahkan fields ke FormData
      storeData.forEach((key, value) {
        if (key == 'accepted_vehicle_types' &&
            value != null &&
            value is List<String>) {
          for (var type in value) {
            formData.fields.add(MapEntry('accepted_vehicle_types[]', type));
          }
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Tambahkan image
      formData.files.add(
        MapEntry(
          'image',
          await dio_pkg.MultipartFile.fromFile(
            pickedImage!.path,
            filename: pickedImage!.name,
          ),
        ),
      );

      final response = await dio_pkg.Dio().post(
        ApiBase.uri('store/register').toString(),
        data: formData,
        options: dio_pkg.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      debugPrint('Fields yang dikirim:');
      formData.fields.forEach((f) => debugPrint('${f.key}: ${f.value}'));

      debugPrint('Files yang dikirim:');
      formData.files.forEach(
        (f) => debugPrint('${f.key}: ${f.value.filename}'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar("Sukses", "Bengkel berhasil ditambahkan");
        Get.offAll(() => const DashboardOwnerScreen(), arguments: 0);
      } else {
        Get.snackbar("Error", "Gagal menambahkan bengkel");
      }
    } catch (e) {
      debugPrint("❌ Error submit: $e");
      Get.snackbar("Error", "Terjadi kesalahan saat submit");
    } finally {
      setState(() => isLoading = false);
    }
  }
}

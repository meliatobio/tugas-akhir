import 'dart:io';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:bengkel/features/owner/services/store_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileBengkelScreen extends StatefulWidget {
  final StoreModel store;

  const EditProfileBengkelScreen({super.key, required this.store});

  @override
  State<EditProfileBengkelScreen> createState() =>
      _EditProfileBengkelScreenState();
}

class _EditProfileBengkelScreenState extends State<EditProfileBengkelScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController storeNameController;
  late TextEditingController storeAddressController;
  late TextEditingController contactNameController;
  late TextEditingController contactPhoneController;
  late TextEditingController latController;
  late TextEditingController longController;
  late TextEditingController openTimeController;
  late TextEditingController closeTimeController;

  List<String> allVehicleTypes = ['mobil', 'motor'];
  List<String> selectedVehicleTypes = [];
  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    storeNameController = TextEditingController(text: widget.store.storeName);
    storeAddressController = TextEditingController(text: widget.store.address);
    contactNameController = TextEditingController(
      text: widget.store.contactName ?? '',
    );
    contactPhoneController = TextEditingController(
      text: widget.store.contact ?? '',
    );
    latController = TextEditingController(
      text: widget.store.lat?.toString() ?? '',
    );
    longController = TextEditingController(
      text: widget.store.long?.toString() ?? '',
    );
    openTimeController = TextEditingController(text: widget.store.openAt);
    closeTimeController = TextEditingController(text: widget.store.closeAt);
    selectedVehicleTypes = List<String>.from(widget.store.acceptedVehicleTypes);
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        validator:
            validator ??
            (value) =>
                (value == null || value.isEmpty) ? 'Tidak boleh kosong' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> _updateStore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await StoreService().updateStoreProfile(
      storeId: widget.store.id,
      storeName: storeNameController.text,
      address: storeAddressController.text,
      contact: contactPhoneController.text,
      contactName: contactNameController.text,
      lat: double.tryParse(latController.text) ?? 0.0,
      long: double.tryParse(longController.text) ?? 0.0,
      openAt: openTimeController.text,
      closeAt: closeTimeController.text,
      acceptedVehicleTypes: selectedVehicleTypes,
      image: imageFile,
    );

    setState(() => isLoading = false);

    if (success) {
      Get.snackbar(
        'Berhasil',
        'Data bengkel berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      if (success) {
        Get.back(result: true); // Kirim "hasil" balik ke screen sebelumnya
      }
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal memperbarui data bengkel',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Bengkel'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: imageFile != null
                            ? FileImage(imageFile!)
                            : (widget.store.image != null &&
                                          widget.store.image!.startsWith('http')
                                      ? NetworkImage(widget.store.image!)
                                      : const AssetImage(
                                          'assets/images/logo.png',
                                        ))
                                  as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField('Nama Bengkel', storeNameController),
                    _buildTextField('Alamat Bengkel', storeAddressController),
                    _buildTextField('Nama Kontak', contactNameController),
                    _buildTextField('Nomor Kontak', contactPhoneController),
                    _buildTextField('Latitude', latController),
                    _buildTextField('Longitude', longController),
                    _buildTextField(
                      'Jam Buka',
                      openTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(context, openTimeController),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    _buildTextField(
                      'Jam Tutup',
                      closeTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(context, closeTimeController),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Jenis Kendaraan yang Dilayani",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: allVehicleTypes.map((type) {
                        return FilterChip(
                          label: Text(type),
                          selected: selectedVehicleTypes.contains(type),
                          onSelected: (selected) {
                            setState(() {
                              selected
                                  ? selectedVehicleTypes.add(type)
                                  : selectedVehicleTypes.remove(type);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _updateStore,
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

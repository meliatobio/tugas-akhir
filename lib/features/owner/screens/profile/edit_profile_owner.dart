import 'package:bengkel/features/auth_owner/services/auth_owner_service.dart';
import 'package:bengkel/features/owner/screens/dashboard/dashboard_owner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bengkel/models/user_model.dart';
import 'package:bengkel/models/bengkel_model.dart';

class EditProfileOwnerScreen extends StatefulWidget {
  final UserModel user;
  final StoreModel store;

  const EditProfileOwnerScreen({
    super.key,
    required this.user,
    required this.store,
  });

  @override
  State<EditProfileOwnerScreen> createState() => _EditProfileOwnerScreenState();
}

class _EditProfileOwnerScreenState extends State<EditProfileOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final box = GetStorage();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    addressController = TextEditingController(text: widget.user.address);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator:
            validator ??
            (value) =>
                (value == null || value.isEmpty) ? 'Tidak boleh kosong' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final token = box.read('token');
    final userSuccess = await AuthOwnerService().updateUserProfile(
      token: token,
      name: nameController.text,
      email: emailController.text.trim(),
      phone: phoneController.text,
      address: addressController.text,
    );

    setState(() => isLoading = false);

    if (userSuccess) {
      final updatedUser = widget.user.copyWith(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        address: addressController.text,
      );
      box.write('user', updatedUser.toJson());

      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => const DashboardOwnerScreen(), arguments: 2);
    } else {
      Get.snackbar(
        'Gagal',
        'Profil gagal diperbarui',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data Pemilik'),
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
                    _buildTextField('Nama Pemilik', nameController),
                    _buildTextField(
                      'Email',
                      emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    _buildTextField('Nomor HP', phoneController),
                    _buildTextField('Alamat Pemilik', addressController),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading ? null : updateUser,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

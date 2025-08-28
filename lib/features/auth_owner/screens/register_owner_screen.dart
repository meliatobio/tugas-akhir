import 'package:bengkel/app/routers.dart';
import 'package:bengkel/features/auth_owner/services/auth_owner_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 40,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 80,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class RegisterOwnerScreen extends StatefulWidget {
  const RegisterOwnerScreen({super.key});

  @override
  State<RegisterOwnerScreen> createState() => _RegisterOwnerScreenState();
}

class _RegisterOwnerScreenState extends State<RegisterOwnerScreen> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final telponController = TextEditingController();
  final alamatController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final namaBengkelController = TextEditingController();
  final alamatBengkelController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  List<String> acceptedVehicleTypes = [];

  bool isPasswordHidden = true;
  bool isLoading = false;

  XFile? _pickedImage;

  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  final List<String> _vehicleTypes = [];
  final _authService = AuthOwnerService();

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleRegister() async {
    if (contactNameController.text.isEmpty ||
        contactPhoneController.text.isEmpty ||
        namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        telponController.text.isEmpty ||
        alamatController.text.isEmpty ||
        namaBengkelController.text.isEmpty ||
        alamatBengkelController.text.isEmpty) {
      Get.snackbar(
        "Gagal",
        "Semua field wajib diisi!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (_pickedImage == null) {
      Get.snackbar(
        "Gagal",
        "Gambar bengkel wajib dipilih!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (_openTime == null || _closeTime == null || _vehicleTypes.isEmpty) {
      Get.snackbar(
        "Gagal",
        "Jam buka/tutup dan jenis kendaraan wajib diisi!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    final userData = {
      "name": namaController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "phone_number": telponController.text,
      "address": alamatController.text,
      "role": "store",
    };

    final registerSuccess = await _authService.registerOwnerAccount(userData);

    if (!registerSuccess) {
      Get.snackbar(
        "Gagal",
        "Registrasi akun owner gagal",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      setState(() => isLoading = false);
      return;
    }

    final loginResult = await _authService.loginOwner(
      emailController.text,
      passwordController.text,
    );

    if (loginResult == null) {
      Get.snackbar(
        "Gagal",
        "Login otomatis gagal setelah register",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      setState(() => isLoading = false);
      return;
    }

    final token = loginResult['token'];
    final userId = loginResult['user']['id'];

    final storeData = {
      "user_id": userId,
      "store_name": namaBengkelController.text,
      "address": alamatBengkelController.text,
      "contact": contactPhoneController.text,
      "contact_name": contactNameController.text,
      "lat": double.tryParse(_latController.text) ?? 0.0,
      "long": double.tryParse(_longController.text) ?? 0.0,
      "open_at": _formatTimeOfDay(_openTime),
      "close_at": _formatTimeOfDay(_closeTime),
      "accepted_vehicle_types": _vehicleTypes,
    };

    final storeSuccess = await _authService.registerStore(
      storeData,
      token,
      _pickedImage!,
    );

    setState(() => isLoading = false);

    if (storeSuccess) {
      Get.snackbar(
        "Sukses",
        "Registrasi Owner & Bengkel berhasil!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routers.login);
    } else {
      Get.snackbar(
        "Gagal",
        "Gagal mendaftarkan Bengkel",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 20, // Tambah jarak kiri-kanan
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                // Layer belakang
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: TopWaveClipper(),
                    child: Container(
                      height: 220,
                      color: const Color(0xFFFFF4CF),
                    ),
                  ),
                ),
                // Layer depan
                ClipPath(
                  clipper: TopWaveClipper(),
                  child: Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFE082), Color(0xFFFFC107)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Get.offAllNamed(
                        Routers.registerrole,
                      ); // arahkan ke register_role
                    },
                  ),
                ),
                // Title
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Register Owner",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withAlpha(204),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            _buildInputField("Nama", namaController),
            _buildInputField(
              "E-mail",
              emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildInputField(
              "No Telepon",
              telponController,
              keyboardType: TextInputType.phone,
            ),
            _buildInputField("Alamat", alamatController),
            _buildInputField(
              "Password",
              passwordController,
              obscure: isPasswordHidden,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => isPasswordHidden = !isPasswordHidden),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: const Text(
                "Data Bengkel",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildInputField("Nama Bengkel", namaBengkelController),
            _buildInputField("Alamat Bengkel", alamatBengkelController),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: const Text(
                "Kontak Bengkel",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildInputField("Nama Kontak Bengkel", contactNameController),
            _buildInputField(
              "No Telepon Kontak Bengkel",
              contactPhoneController,
              keyboardType: TextInputType.phone,
              suffixIcon: const Icon(
                Icons.phone,
                color: Colors.green,
              ), // 📞 hijau
            ),

            _buildInputField(
              "Latitude",
              _latController,
              keyboardType: TextInputType.number,
              suffixIcon: const Icon(
                Icons.location_on,
                color: Colors.red,
              ), // 📍 merah
            ),

            _buildInputField(
              "Longitude",
              _longController,
              keyboardType: TextInputType.number,
              suffixIcon: const Icon(Icons.map, color: Colors.blue), // 🗺️ biru
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Colors.white,
                title: Text(
                  "Jam Buka: ${_openTime?.format(context) ?? 'Pilih waktu'}",
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _openTime = picked);
                },
              ),
            ),

            // ListTile Jam Tutup
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Colors.white,
                title: Text(
                  "Jam Tutup: ${_closeTime?.format(context) ?? 'Pilih waktu'}",
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _closeTime = picked);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: const Text(
                "Jenis Kendaraan yang di layani",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ), // Checkbox Motor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CheckboxListTile(
                title: const Text("Motor"),
                value: _vehicleTypes.contains("motor"),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _vehicleTypes.add("motor");
                    } else {
                      _vehicleTypes.remove("motor");
                    }
                  });
                },
              ),
            ),

            // Checkbox Mobil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CheckboxListTile(
                title: const Text("Mobil"),
                value: _vehicleTypes.contains("mobil"),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _vehicleTypes.add("mobil");
                    } else {
                      _vehicleTypes.remove("mobil");
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // Tombol pilih foto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _pickedImage = image;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // latar putih
                  foregroundColor: const Color(
                    0xFF333333,
                  ), // teks abu-abu kehitaman
                  minimumSize: const Size.fromHeight(50),
                  elevation: 3, // bayangan halus
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFFCCCCCC), // border abu-abu tipis
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _pickedImage == null
                          ? "Pilih Foto Bengkel"
                          : "Foto Bengkel Dipilih",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Sign Up
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sudah punya akun? "),
                TextButton(
                  onPressed: () => Get.toNamed(Routers.login),
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            // Tambahkan jarak di bawah
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

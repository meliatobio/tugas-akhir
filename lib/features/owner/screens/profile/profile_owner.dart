import 'dart:convert';
import 'dart:io';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/auth_owner/services/auth_owner_service.dart';
import 'package:bengkel/features/owner/services/store_service.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:bengkel/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileOwnerScreen extends StatefulWidget {
  const ProfileOwnerScreen({super.key});

  @override
  State<ProfileOwnerScreen> createState() => _ProfileOwnerScreenState();
}

class _ProfileOwnerScreenState extends State<ProfileOwnerScreen> {
  final storeService = StoreService();
  bool isEditingUser = false;
  bool isUserLoading = false;
  final StoreService _authService = StoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final email = GetStorage().read('email');
  final authService = AuthOwnerService();
  final box = GetStorage();
  UserModel? user;

  String token = '';
  bool isLoading = true;
  List<StoreModel> localStoreList = [];
  List<StoreModel> stores = [];
  List<bool> isStoreLoading = []; // untuk per store (edit simpan)
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> addressControllers = [];
  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> contactNameControllers = [];
  List<TextEditingController> openAtControllers = [];
  List<TextEditingController> closeAtControllers = [];
  List<TextEditingController> latControllers = [];
  List<TextEditingController> longControllers = [];
  List<List<String>> selectedVehicleTypes = []; // untuk kendaraan mobil/motor
  // state
  List<File?> selectedStoreImages = [];

  List<bool> isEditing = [];

  @override
  void initState() {
    super.initState();
    selectedStoreImages = List.generate(localStoreList.length, (_) => null);
    final userMap = GetStorage().read('user');
    if (userMap != null) {
      user = UserModel.fromJson(userMap);
    } else {
      debugPrint("User tidak ditemukan di storage");
      return; // ⛔ Hindari jalankan _initializeData kalau user null
    }

    _initializeData();
  }

  Future<void> _initializeData() async {
    final box = GetStorage();
    nameController.text = user!.name;
    emailController.text = user!.email;
    phoneController.text = user!.phone;
    addressController.text = user!.address;

    final dynamic userRaw = box.read('user');
    final savedToken = box.read('token') ?? '';
    token = savedToken;

    Map<String, dynamic> userMap = {};
    if (userRaw is Map<String, dynamic>) {
      userMap = userRaw;
    } else if (userRaw is String) {
      try {
        userMap = jsonDecode(userRaw);
      } catch (e) {
        debugPrint("❌ Gagal decode user dari string: $e");
      }
    }

    user = UserModel.fromJson(userMap);
    await _loadStoreData();
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Ubah Password"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Lama'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              final oldPass = oldPasswordController.text.trim();
              final newPass = newPasswordController.text.trim();
              final confirmPass = confirmPasswordController.text.trim();

              if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                Get.snackbar("Error", "Semua field harus diisi");
                return;
              }

              if (newPass != confirmPass) {
                Get.snackbar("Error", "Konfirmasi password tidak cocok");
                return;
              }

              final success = await _authService.changePassword(
                oldPassword: oldPass,
                newPassword: newPass,
                confirmPassword: confirmPass,
              );

              if (success) {
                Get.back();
                Get.snackbar(
                  "Berhasil",
                  "Password berhasil diubah",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  "Gagal",
                  "Password gagal diubah",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStoreData() async {
    try {
      final fetchedStores = await storeService.getAllOwnedStores(token);

      setState(() {
        localStoreList = fetchedStores;
        isStoreLoading = List.filled(localStoreList.length, false);

        // reset semua controller/list
        nameControllers = [];
        addressControllers = [];
        phoneControllers = [];
        contactNameControllers = [];
        openAtControllers = [];
        closeAtControllers = [];
        latControllers = [];
        longControllers = [];
        selectedVehicleTypes = [];
        selectedStoreImages = List<File?>.filled(
          localStoreList.length,
          null,
        ); // 👈 WAJIB
        isEditing = [];

        for (var store in localStoreList) {
          nameControllers.add(TextEditingController(text: store.storeName));
          addressControllers.add(
            TextEditingController(text: store.address ?? ''),
          );
          phoneControllers.add(
            TextEditingController(text: store.contact ?? ''),
          );
          contactNameControllers.add(
            TextEditingController(text: store.contactName ?? ''),
          );
          openAtControllers.add(
            TextEditingController(text: store.openAt ?? ''),
          );
          closeAtControllers.add(
            TextEditingController(text: store.closeAt ?? ''),
          );
          latControllers.add(
            TextEditingController(text: store.lat?.toString() ?? ''),
          );
          longControllers.add(
            TextEditingController(text: store.long?.toString() ?? ''),
          );
          selectedVehicleTypes.add(
            List<String>.from(store.acceptedVehicleTypes),
          );

          isEditing.add(false);
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading store data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    final double appBarStackHeight =
        statusBar + kToolbarHeight + kTextTabBarHeight;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.grey,
            tabs: [
              Tab(text: 'Data Pemilik'),
              Tab(text: 'Data Bengkel'),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Wave Background (di belakang AppBar + konten)
            ClipPath(
              clipper: BookingWaveClipper2(),
              child: Container(height: 220, color: Colors.yellow.shade200),
            ),
            ClipPath(
              clipper: BookingWaveClipper1(),
              child: Container(height: 200, color: Colors.amber),
            ),

            // Konten Tab
            Padding(
              padding: EdgeInsets.only(top: appBarStackHeight + 12),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [_buildOwnerTab(), _buildWorkshopTab()],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked == null) return;

                  final url = await authService.uploadProfilePicture(
                    File(picked.path),
                  );
                  if (url != null) {
                    setState(() {});
                    Get.snackbar("Sukses", "Foto profil berhasil diperbarui");
                  }
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: box.read('profile_pict') != null
                      ? NetworkImage(box.read('profile_pict'))
                      : null,
                  child: box.read('profile_pict') == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hi, ${user!.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Data Pemilik",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          isEditingUser
              ? _buildTextField('Nama', nameController)
              : _buildProfileField('Nama', user!.name),
          isEditingUser
              ? _buildTextField('Email', emailController)
              : _buildProfileField('Email', user!.email),
          isEditingUser
              ? _buildTextField('Alamat', addressController)
              : _buildProfileField('Alamat', user!.address),
          isEditingUser
              ? _buildTextField('No. Telepon', phoneController)
              : _buildProfileField(
                  'No. Telepon',
                  user!.phone.isNotEmpty ? user!.phone : '-',
                ),
          const SizedBox(height: 25),

          // 🔹 Button Edit / Simpan Profil
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                if (isEditingUser) {
                  if (nameController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❗ Semua field harus diisi.'),
                      ),
                    );
                    return;
                  }

                  setState(() => isUserLoading = true);

                  final success = await storeService.updateUserProfile(
                    name: nameController.text,
                    email: emailController.text,
                    phoneNumber: phoneController.text,
                    address: addressController.text,
                  );

                  if (success) {
                    setState(() {
                      user = user?.copyWith(
                        name: nameController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        address: addressController.text,
                      );
                      isEditingUser = false;
                    });

                    final box = GetStorage();
                    box.write('user', user?.toJson());

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Profil berhasil diperbarui'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Gagal memperbarui profil'),
                      ),
                    );
                  }

                  setState(() => isUserLoading = false);
                } else {
                  setState(() => isEditingUser = true);
                }
              },
              icon: isUserLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Icon(
                      isEditingUser ? Icons.save_rounded : Icons.edit_rounded,
                      size: 18,
                    ),
              label: Text(
                isEditingUser ? 'Simpan Perubahan' : 'Edit Profil',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade200,
                foregroundColor: Colors.black,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Button Ubah Password
          ElevatedButton.icon(
            onPressed: _showChangePasswordDialog,
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text(
              "Ubah Password",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Button Logout
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white,
                  titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  // 🔹 Judul dengan icon
                  title: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: Colors.red, size: 26),
                      SizedBox(width: 10),
                      Text(
                        "Konfirmasi Logout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // 🔹 Isi konten
                  content: const Text(
                    "Apakah kamu yakin ingin keluar dari akun ini?",
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),

                  // 🔹 Tombol aksi
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        GetStorage().erase();
                        Navigator.of(context).pop();
                        Get.offAllNamed(Routers.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Bengkel Anda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...localStoreList.asMap().entries.map((entry) {
            int index = entry.key;
            final store = entry.value;
            final isEditMode = isEditing[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(51),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ FOTO BENGKEL
                    Center(
                      child: GestureDetector(
                        onTap: isEditMode
                            ? () async {
                                final picked = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedStoreImages[index] = File(
                                      picked.path,
                                    );
                                  });
                                }
                              }
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: selectedStoreImages[index] != null
                              ? Image.file(
                                  selectedStoreImages[index]!,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : (store.image != null
                                    ? Image.network(
                                        "${ApiBase.imageUrl}${store.image!}",
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 150,
                                                height: 150,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.store,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      )
                                    : null),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ MODE EDIT ATAU TAMPILAN NORMAL
                    isEditMode
                        ? Column(
                            children: [
                              _buildTextField(
                                'Nama Bengkel',
                                nameControllers[index],
                              ),
                              _buildTextField(
                                'Alamat',
                                addressControllers[index],
                              ),
                              _buildTextField(
                                'Kontak',
                                phoneControllers[index],
                              ),
                              _buildTextField(
                                'Nama Kontak',
                                contactNameControllers[index],
                              ),
                              _buildTextField(
                                'Jam Buka (HH:mm)',
                                openAtControllers[index],
                              ),
                              _buildTextField(
                                'Jam Tutup (HH:mm)',
                                closeAtControllers[index],
                              ),
                              _buildTextField(
                                'Latitude',
                                latControllers[index],
                              ),
                              _buildTextField(
                                'Longitude',
                                longControllers[index],
                              ),

                              // ✅ Tombol Simpan
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Tombol Simpan
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: isStoreLoading[index]
                                          ? null
                                          : () async {
                                              setState(() {
                                                isStoreLoading[index] = true;
                                              });

                                              final isSuccess = await storeService
                                                  .updateStoreProfile(
                                                    storeId: store.id,
                                                    storeName:
                                                        nameControllers[index]
                                                            .text,
                                                    address:
                                                        addressControllers[index]
                                                            .text,
                                                    contact:
                                                        phoneControllers[index]
                                                            .text,
                                                    contactName:
                                                        contactNameControllers[index]
                                                            .text,
                                                    lat:
                                                        double.tryParse(
                                                          latControllers[index]
                                                              .text,
                                                        ) ??
                                                        0.0,
                                                    long:
                                                        double.tryParse(
                                                          longControllers[index]
                                                              .text,
                                                        ) ??
                                                        0.0,
                                                    openAt:
                                                        openAtControllers[index]
                                                            .text,
                                                    closeAt:
                                                        closeAtControllers[index]
                                                            .text,
                                                    acceptedVehicleTypes:
                                                        selectedVehicleTypes[index],
                                                    image:
                                                        selectedStoreImages[index],
                                                  );

                                              setState(() {
                                                isStoreLoading[index] = false;
                                              });

                                              if (isSuccess) {
                                                await _loadStoreData();
                                                setState(() {
                                                  isEditing[index] = false;
                                                  selectedStoreImages[index] =
                                                      null;
                                                });
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      '✅ Bengkel berhasil diperbarui',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      '❌ Gagal memperbarui data bengkel',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      child: isStoreLoading[index]
                                          ? const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            )
                                          : const Text(
                                              "💾 Simpan",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // Tombol Batal
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditing[index] = false;
                                          selectedStoreImages[index] =
                                              null; // reset image kalau perlu
                                        });
                                      },
                                      child: const Text(
                                        "❌ Batal",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileField(
                                'Nama Bengkel',
                                store.storeName,
                              ),
                              _buildProfileField(
                                'Alamat',
                                store.address ?? '-',
                              ),
                              _buildProfileField(
                                'Kontak',
                                store.contact ?? '-',
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isEditing[index] = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProfileField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

// =====================
// Wave clippers (Booking)
// =====================
class BookingWaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height - 10);
    var firstEndPoint = Offset(size.width / 2, size.height - 25);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 40);
    var secondEndPoint = Offset(size.width, size.height - 5);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BookingWaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 35);
    var secondEndPoint = Offset(size.width, size.height - 8);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

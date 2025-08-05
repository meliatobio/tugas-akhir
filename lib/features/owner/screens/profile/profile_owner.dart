import 'dart:convert';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/features/auth_owner/services/auth_owner_service.dart';
import 'package:bengkel/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// import tetap sama...

class ProfileOwnerScreen extends StatelessWidget {
  const ProfileOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final dynamic userRaw = box.read('user');
    final token = box.read('token') ?? '';
    debugPrint('🔎 User dari storage: ${box.read('user')}');

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

    final user = UserModel.fromJson(userMap);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Data Pemilik'),
              Tab(text: 'Data Bengkel'),
            ],
          ),
        ),
        body: FutureBuilder(
          future: AuthOwnerService().getOwnedStore(token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Center(child: Text("Gagal memuat data bengkel."));
            }

            final store = snapshot.data!;

            return TabBarView(
              children: [
                // 🧑 Tab 1: Data Pemilik
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFFD9D9D9),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Hi, ${user.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Data Pemilik",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField('Nama', user.name),
                      const SizedBox(height: 12),
                      _buildProfileField('Email', user.email),
                      const SizedBox(height: 12),
                      _buildProfileField('Alamat', user.address),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        'No. Telepon',
                        user.phone.isNotEmpty ? user.phone : '-',
                      ),
                      const SizedBox(height: 30),

                      // ✅ Tombol Edit Pemilik
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed(
                              Routers.editprofileowner,
                              arguments: {
                                'user': user,
                                'store': store,
                                'token': token,
                              },
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Data Pemilik'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ✅ Tombol Logout (hanya di tab pemilik)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Konfirmasi Logout"),
                                content: const Text(
                                  "Apakah kamu yakin ingin logout?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Batal"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      box.erase();
                                      Navigator.of(context).pop();
                                      Get.offAllNamed(Routers.start);
                                    },
                                    child: const Text(
                                      "Logout",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🛠️ Tab 2: Data Bengkel
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.grey[200],
                          child:
                              (store.image != null &&
                                  store.image!.isNotEmpty &&
                                  store.image!.startsWith('http'))
                              ? Image.network(store.image!, fit: BoxFit.cover)
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField('Nama Bengkel', store.storeName),
                      const SizedBox(height: 12),
                      _buildProfileField('Alamat', store.address ?? '-'),
                      const SizedBox(height: 12),
                      _buildProfileField('Kontak', store.contact ?? '-'),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        'Kontak Nama',
                        store.contactName ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        'Latitude',
                        store.lat?.toString() ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        'Longitude',
                        store.long?.toString() ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _buildProfileField('Open At', store.openAt ?? '-'),
                      const SizedBox(height: 12),
                      _buildProfileField('Close At', store.closeAt ?? '-'),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        'Jenis Kendaraan yang di layani',
                        (store.acceptedVehicleTypes.isNotEmpty)
                            ? store.acceptedVehicleTypes.join(', ')
                            : '-',
                      ),
                      const SizedBox(height: 30),

                      // ✅ Tombol Edit Bengkel
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Get.toNamed(
                              Routers.editprofilebengkel,
                              arguments: {'store': store},
                            );

                            if (result == true) {
                              // TODO: Refresh store data atau pindah ke tab 'Data Bengkel'
                              // Contoh: Jika kamu punya _loadStoreData()
                              // _loadStoreData();

                              // Atau jika pakai TabController:
                              // _tabController.animateTo(1);
                            }
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Profil Bengkel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE0E0E0),
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(value, style: const TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}

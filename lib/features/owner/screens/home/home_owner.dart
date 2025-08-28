import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/owner/screens/bengkel/manajemen_bengkel_screen.dart';
import 'package:bengkel/features/owner/services/store_service.dart';
import 'package:bengkel/shared/widgets/wave_backround.dart';
import 'package:bengkel/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bengkel/models/bengkel_model.dart';

class HomeOwnerScreen extends StatefulWidget {
  const HomeOwnerScreen({super.key});

  @override
  State<HomeOwnerScreen> createState() => _HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends State<HomeOwnerScreen> {
  final box = GetStorage();
  StoreModel? store;
  bool isLoading = true;
  bool isEmergencyOn = true;
  List<StoreModel> stores = [];

  @override
  void initState() {
    super.initState();
    fetchOwnerStores();
  }

  void loadOwnerData() {
    final role = box.read('role');
    final userData = box.read('user');

    if (role == 'store' && userData != null) {
      final user = UserModel.fromJson(userData);
      debugPrint("✅ User dari storage: ${user.name}");
      fetchStore(user.id);
    } else {
      debugPrint("❌ Token kosong atau role bukan owner.");
    }
  }

  void fetchStore(int userId) async {
    final fetchedStore = await StoreService().fetchStoreDetail();
    debugPrint('📦 Data dari fetchStoreDetail: $fetchedStore');
    setState(() {
      store = fetchedStore;
      isLoading = false;
    });
  }

  Future<void> fetchOwnerStores() async {
    setState(() => isLoading = true);

    final role = box.read('role');
    final token = box.read('token');

    if (token == null || role != 'store') {
      debugPrint('❌ Token kosong atau role bukan owner.');
      setState(() => isLoading = false);
      return;
    }

    try {
      final fetchedStores = await StoreService().fetchStores();
      debugPrint('📦 Data stores: $fetchedStores');
      setState(() {
        stores = fetchedStores;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Gagal mengambil data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (stores.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada bengkel terdaftar')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Wave Background
          ClipPath(
            clipper: BookingWaveClipper2(),
            child: Container(height: 120, color: Colors.yellow.shade200),
          ),
          ClipPath(
            clipper: BookingWaveClipper1(),
            child: Container(height: 100, color: Colors.amber),
          ),

          // Konten utama
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    "Bengkel Anda",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.white,
                            titlePadding: const EdgeInsets.fromLTRB(
                              24,
                              20,
                              24,
                              0,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              24,
                              16,
                              24,
                              0,
                            ),
                            actionsPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),

                            // 🔹 Judul dengan icon
                            title: Row(
                              children: const [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red,
                                  size: 26,
                                ),
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
                                  GetStorage().erase(); // hapus semua session
                                  Navigator.of(context).pop();
                                  Get.offAllNamed(
                                    Routers.login,
                                  ); // pindah ke login
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
                    ),
                  ],
                ),

                // List bengkel dengan pull-to-refresh
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchOwnerStores,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        final isActive = store.active;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 📸 Foto Bengkel
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                        (store.image != null &&
                                            store.image!.isNotEmpty)
                                        ? Image.network(
                                            "${ApiBase.imageUrl}${store.image!}", // ✅ ambil dari API
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 80,
                                                  height: 80,
                                                ),
                                          )
                                        : Image.asset(
                                            'assets/images/logo.png',
                                            width: 80,
                                            height: 80,
                                          ),
                                  ),
                                  const SizedBox(width: 12),

                                  // 📋 Detail Bengkel
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 🔹 Nama + Status
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                store.storeName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? Colors.green.shade100
                                                    : Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    color: isActive
                                                        ? Colors.green
                                                        : Colors.red,
                                                    size: 10,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isActive ? 'Buka' : 'Tutup',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isActive
                                                          ? Colors
                                                                .green
                                                                .shade800
                                                          : Colors.red.shade800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // 🔹 Alamat
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                store.address ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        // 🔹 Telepon
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              store.contact ?? '-',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // 🔹 Tombol Kelola
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    38,
                                                  ),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Get.to(
                                                  () => ManajemenBengkelScreen(
                                                    store: store,
                                                    allStores: stores,
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.yellow.shade200,
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                elevation: 0,
                                              ),
                                              child: const Text("Kelola"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Tombol tambah bengkel
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.toNamed(Routers.tambahbengkel);
              if (result == 'refresh') {
                fetchOwnerStores();
              }
            },
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text('Tambah Bengkel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

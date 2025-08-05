import 'package:bengkel/features/owner/services/store_service.dart';
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
      print("✅ User dari storage: ${user.name}");
      // Bisa lanjut ambil detail store pakai user.id
      fetchStore(user.id);
    } else {
      print("❌ Token kosong atau role bukan owner.");
    }
  }

  void fetchStore(int userId) async {
    // contoh pakai StoreService
    final fetchedStore = await StoreService().fetchStoreDetail();
    print('📦 Data dari fetchStoreDetail: $fetchedStore');
    setState(() {
      store = fetchedStore;
      isLoading = false;
    });
  }

  void fetchOwnerStores() async {
    final role = box.read('role');
    final token = box.read('token');

    if (token == null || role != 'store') {
      print('❌ Token kosong atau role bukan owner.');
      setState(() => isLoading = false);
      return;
    }

    try {
      final fetchedStores = await StoreService()
          .fetchStores(); // GANTI METHOD INI
      print('📦 Data stores: $fetchedStores');
      setState(() {
        stores = fetchedStores;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal mengambil data: $e');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bengkel Anda'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          final isActive = store.isActive; // Sesuaikan field status
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    store.photo ?? '', // Ganti dengan URL foto
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          Icon(
                            Icons.circle,
                            color: isActive ? Colors.green : Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(isActive ? 'Aktif' : 'Tidak Aktif'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(store.contact ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed('/manajemenbengkel', arguments: store);
                          },
                          child: const Text("Kelola"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

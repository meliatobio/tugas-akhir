import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  List<StoreModel> stores = [];
  bool isLoading = true;

  final box = GetStorage();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores({String query = ''}) async {
    final token = box.read('token');
    final url = Uri.parse(
      '${ApiBase.baseUrl}store${query.isNotEmpty ? '?search=$query' : ''}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data'];

        setState(() {
          stores = data.map((e) => StoreModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data store');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah kamu yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              box.erase();
              Navigator.of(context).pop();
              Get.offAllNamed(Routers.login);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              radius: 14,
            ),
            const SizedBox(width: 8),
            const Text(
              'OntoCare',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchStores(query: _searchController.text),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 🔍 Search, Banner, Emergency
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // warna shadow
                      blurRadius: 8, // seberapa lembut shadow
                      offset: const Offset(0, 4), // arah jatuh shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search bar
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routers.searchbengkel);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10, // 🔹 lebih tipis dari 14
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Cari Bengkel...",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Icon(
                              Icons.search_rounded,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/banner.png',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Emergency Button
              Center(
                child: SizedBox(
                  width: 220, // biar nggak terlalu lebar
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routers.emergency),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.red.withOpacity(0.4),
                    ),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text(
                      'Emergency Call',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              // 📍 Bengkel Terdekat
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + arrow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.place, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "Bengkel Terdekat",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(Routers.bengkelterdekat);
                          },
                          child: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // List bengkel
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : stores.isEmpty
                        ? const Text("Bengkel tidak ditemukan.")
                        : Column(
                            children: stores.map((store) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                      Routers.detailbengkel,
                                      arguments: store.id,
                                    );
                                  },
                                  child: _buildBengkelCard(store),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🏪 Card Bengkel
  Widget _buildBengkelCard(StoreModel store) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              'assets/images/banner.png',
              // Kalau API sudah ada gambar, ganti ke:
              // Image.network('${ApiBase.baseUrl}${store.image}', ...
              width: 100,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${store.rating?.toStringAsFixed(1) ?? '0.0'}/5",
                        style: const TextStyle(fontSize: 12),
                      ),
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
                          store.address ?? 'Alamat tidak tersedia',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '1 KM',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCustomAppBar(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: const BoxDecoration(
  //       color: Colors.amber,
  //       borderRadius: BorderRadius.only(
  //         bottomLeft: Radius.circular(20),
  //         bottomRight: Radius.circular(20),
  //       ),
  //     ),
  //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
  //     child: SafeArea(
  //       bottom: false,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Baris atas: Logo + Logout
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Row(
  //                 children: const [
  //                   CircleAvatar(
  //                     backgroundColor: Colors.white,
  //                     radius: 14,
  //                     child: Icon(Icons.build, color: Colors.amber),
  //                   ),
  //                   SizedBox(width: 8),
  //                   Text(
  //                     'OntoCare',
  //                     style: TextStyle(
  //                       fontFamily: 'Poppins',
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 18,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               IconButton(
  //                 icon: const Icon(Icons.logout, color: Colors.white),
  //                 onPressed: () => _showLogoutConfirmation(context),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           // Search Bar
  //           GestureDetector(
  //             onTap: () {
  //               Get.toNamed(Routers.searchbengkel);
  //             },
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 14,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(12),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.05),
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 2),
  //                   ),
  //                 ],
  //               ),
  //               child: Row(
  //                 children: const [
  //                   Icon(Icons.search, color: Colors.grey),
  //                   SizedBox(width: 8),
  //                   Text(
  //                     "Cari Bengkel...",
  //                     style: TextStyle(color: Colors.grey, fontSize: 14),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

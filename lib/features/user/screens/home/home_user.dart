import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/user/widgets/start_rating.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // jangan lupa import ini
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Text(
              "Konfirmasi Logout",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          "Apakah kamu yakin ingin logout?",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await box.erase();
              Navigator.of(context).pop();
              Get.offAllNamed(Routers.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Logout"),
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
            Container(
              width: 32, // diameter bulatan putih
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // bulatan putih di belakang
              ),
              child: CircleAvatar(
                radius: 14, // radius avatar yang lebih kecil
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
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
                      color: Colors.black.withAlpha(26), // warna shadow
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
                              color: Colors.black.withAlpha(128),
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
                          color: Colors.black.withAlpha(204),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        const double latitude =
                            -0.941341; // ganti dengan latitude sebenarnya
                        const double longitude =
                            100.373652; // ganti dengan longitude sebenarnya
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tidak bisa membuka Google Maps'),
                            ),
                          );
                        }
                      },
                      child: Image.asset(
                        'assets/images/map_placeholder.png', // gambar map statis di assets
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
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
                      shadowColor: Colors.red.withAlpha(102),
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
                                "Daftar Bengkel",
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
                            Get.toNamed(Routers.daftarbengkel);
                          },
                          child: const Text(
                            "Lihat Semua",
                            style: TextStyle(
                              color: Colors.green, // warna tulisan
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                            children: [
                              ...stores.take(3).map((store) {
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
                            ],
                          ),
                  ],
                ),
              ),
              // Setelah list Daftar Bengkel, tambahkan ini:
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Bengkel Rekomendasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : stores.isEmpty
                  ? const Text("Tidak ada rekomendasi.")
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Builder(
                        builder: (_) {
                          // Urutkan stores berdasarkan rating sebelum ditampilkan
                          final sortedStores = List<StoreModel>.from(stores)
                            ..sort(
                              (a, b) =>
                                  (b.rating ?? 0).compareTo(a.rating ?? 0),
                            );

                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 3 / 3,
                            children: sortedStores.take(4).map((store) {
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    Routers.detailbengkel,
                                    arguments: store.id,
                                  );
                                },
                                child: _buildRekomendasiCard(store),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildRekomendasiCard(StoreModel store) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(26),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: store.image != null && store.image!.isNotEmpty
                ? Image.network(
                    '${ApiBase.imageUrl}${store.image}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/banner.png',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset('assets/images/banner.png', fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store.storeName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...buildStarRating(store.rating ?? 0, iconSize: 14),
                  const SizedBox(width: 4),
                  Text(
                    "${store.rating?.toStringAsFixed(1) ?? '0.0'}",
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),

              Text(
                store.address ?? 'Alamat tidak tersedia',
                style: const TextStyle(color: Colors.black54, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    ),
  );
}

// 🏪 Card Bengkel
Widget _buildBengkelCard(StoreModel store, {VoidCallback? onTap}) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 12), // ⬅️ kiri 0, kanan ada space
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          Padding(
            padding: const EdgeInsets.all(12),
            child: // 📍 di _buildBengkelCard
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: store.image != null && store.image!.isNotEmpty
                  ? Image.network(
                      '${ApiBase.imageUrl}${store.image}', // gabungkan base url + path gambar
                      width: 120,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/banner.png',
                          width: 120,
                          height: 85,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/banner.png',
                      width: 120,
                      height: 85,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // Info bengkel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chip status buka/tutup
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: store.active == true
                            ? Colors.green.withAlpha(26)
                            : Colors.red.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        store.active == true ? "Buka" : "Tutup",
                        style: TextStyle(
                          color: store.active == true
                              ? Colors.green
                              : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Nama bengkel
                  Text(
                    store.storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Rating
                  Row(
                    children: [
                      ...buildStarRating(store.rating ?? 0, iconSize: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${store.rating?.toStringAsFixed(1) ?? '0.0'}/5",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Alamat
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
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
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
        ],
      ),
    ),
  );
}

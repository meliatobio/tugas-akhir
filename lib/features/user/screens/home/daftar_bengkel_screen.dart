import 'package:bengkel/features/user/widgets/start_rating.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/app/routers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class DaftarBengkelScreen extends StatefulWidget {
  const DaftarBengkelScreen({super.key});

  @override
  State<DaftarBengkelScreen> createState() => _DaftarBengkelScreenState();
}

class _DaftarBengkelScreenState extends State<DaftarBengkelScreen> {
  List<StoreModel> stores = [];
  bool isLoading = true;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    final token = box.read('token');
    final url = Uri.parse('${ApiBase.baseUrl}store');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Bengkel",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final store = stores[index];
                return GestureDetector(
                  onTap: () {
                    Get.toNamed(Routers.detailbengkel, arguments: store.id);
                  },
                  child: _buildBengkelCard(store),
                );
              },
            ),
    );
  }
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

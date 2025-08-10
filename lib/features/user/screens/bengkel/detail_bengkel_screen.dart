import 'dart:convert';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/models/detail_bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:bengkel/services/storage_service.dart';

class DetailBengkelScreen extends StatefulWidget {
  const DetailBengkelScreen({super.key});

  @override
  State<DetailBengkelScreen> createState() => _DetailBengkelScreenState();
}

class _DetailBengkelScreenState extends State<DetailBengkelScreen> {
  DetailStoreModel? storeDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final arg = Get.arguments;
    final id = (arg is int) ? arg : int.tryParse(arg.toString());
    if (id != null) {
      fetchDetail(id); // Kirim id ke fungsi
    } else {
      debugPrint('❌ ID tidak valid dari Get.arguments');
    }
  }

  Future<void> fetchDetail(int id) async {
    if (id <= 0) {
      debugPrint('❌ ID store tidak valid: $id');
      return;
    }

    final token = StorageService.token;
    if (token == null) {
      debugPrint('❌ Token tidak ditemukan');
      return;
    }

    final url = '${ApiBase.baseUrl}store/$id';
    debugPrint('🧪 ID: $id');
    debugPrint('🔐 TOKEN: $token');
    debugPrint('🔗 URL: $url');
    debugPrint('📦 GET ARGUMENTS: ${Get.arguments}');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 STATUS: ${response.statusCode}');
      debugPrint('📡 BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          storeDetail = DetailStoreModel.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil detail store');
      }
    } catch (e) {
      debugPrint('❌ Error fetchDetail: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (storeDetail == null) {
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan.")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/banner.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(102),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              // Info utama
              Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 166, 51),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                          bottom: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                storeDetail!.storeName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("1,3 KM"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 18,
                              ),
                              Text(
                                " ${storeDetail!.rating.toStringAsFixed(1)}/5",
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Jam Operasional: ${storeDetail!.openAt.substring(0, 5)} - ${storeDetail!.closeAt.substring(0, 5)} WIB",
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Kontak: ${storeDetail!.contact} (${storeDetail!.contactName})",
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(child: Text("Peta Lokasi")),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Layanan
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Text(
                      "Layanan yang tersedia",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...storeDetail!.services.map(
                      (service) => ExpansionTile(
                        title: Text(service.name),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text("Harga: Rp ${service.price}"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            Routers.inputbooking,
                            arguments: {
                              'layananList': storeDetail!.services,
                              'storeId': Get.arguments,
                            },
                          );
                        },
                        child: const Text("BOOKING"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text(
                      "💬 Ulasan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...storeDetail!.reviews.map((r) {
                      final int ratingInt = r.rating.floor();
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    Icons.star,
                                    size: 18,
                                    color: index < ratingInt
                                        ? Colors.orange
                                        : Colors.grey,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text("“${r.comment}”"),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

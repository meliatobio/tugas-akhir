import 'dart:convert';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/owner/services/store_service.dart';
import 'package:bengkel/features/user/widgets/start_rating.dart';
import 'package:bengkel/models/detail_bengkel_model.dart';
import 'package:bengkel/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:bengkel/services/storage_service.dart';

class DetailBengkelScreen extends StatefulWidget {
  const DetailBengkelScreen({super.key});

  @override
  State<DetailBengkelScreen> createState() => _DetailBengkelScreenState();
}

class _DetailBengkelScreenState extends State<DetailBengkelScreen> {
  DetailStoreModel? storeDetail;
  bool isLoading = true;
  bool canReview = false; // state baru

  // state untuk form review
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    final id = (arg is int) ? arg : int.tryParse(arg.toString());
    if (id != null) fetchDetail(id);
  }

  Future<void> fetchDetail(int id) async {
    setState(() => isLoading = true);

    final token = StorageService.token;
    if (token == null || token.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    final url = '${ApiBase.baseUrl}store/$id';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          storeDetail = DetailStoreModel.fromJson(jsonData['data']);
        });

        // ✅ Cek apakah user boleh review
        final result = await StoreService.checkCanReview(id);
        setState(() => canReview = result);
      }
    } catch (e) {
      debugPrint('❌ fetchDetail error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> openGoogleMaps(double lat, double long) async {
    if (lat != 0.0 && long != 0.0) {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$long',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (storeDetail == null)
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan.")));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Banner Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        storeDetail!.image != null &&
                            storeDetail!.image!.isNotEmpty
                        ? Image.network(
                            '${ApiBase.imageUrl}${storeDetail!.image}',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                  'assets/images/banner.png',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                          )
                        : Image.asset(
                            'assets/images/banner.png',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
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
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeDetail!.storeName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...buildStarRating(storeDetail!.rating, iconSize: 20),
                          const SizedBox(width: 6),
                          Text("${storeDetail!.rating.toStringAsFixed(1)}/5"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Info icon
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Melayani Kendaraan: ${storeDetail!.acceptedVehicleTypes.join(', ')}",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Jam Operasional: ${storeDetail!.openAt.substring(0, 5)} - ${storeDetail!.closeAt.substring(0, 5)} WIB",
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Kontak: ${storeDetail!.contact} (${storeDetail!.contactName})",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Map Card
                      InkWell(
                        onTap: () =>
                            openGoogleMaps(storeDetail!.lat, storeDetail!.long),
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Container(
                              height: 130,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/map_placeholder.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(30),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 130,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black.withAlpha(60),
                              ),
                            ),
                            const Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Lihat Lokasi",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Layanan
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(thickness: 1.2),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.build, color: Colors.amber[700], size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Layanan yang tersedia",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (storeDetail!.services.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Belum ada Layanan",
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    else
                      ...storeDetail!.services.map(
                        (service) => Card(
                          elevation: 4,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              collapsedBackgroundColor: Colors.amber[50],
                              backgroundColor: Colors.amber[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                service.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    "Harga: Rp ${service.price}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Tombol Booking
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.amber[600],
                        ),
                        onPressed: () {
                          Get.toNamed(
                            Routers.inputbooking,
                            arguments: {
                              'layananList': storeDetail!.services,
                              'storeId': storeDetail!.id,
                              'vehicleType': storeDetail!.acceptedVehicleTypes,
                              'openAt': storeDetail!.openAt,
                              'closeAt': storeDetail!.closeAt,
                            },
                          );
                        },
                        child: const Text(
                          "BOOKING",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(thickness: 1.2),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          color: Colors.amber[700],
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Ulasan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // List review lama
                    ...storeDetail!.reviews.map((r) {
                      final int ratingInt = r.rating.floor();
                      return Card(
                        elevation: 3,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < ratingInt
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "“${r.comment}”",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    // Form review (hanya kalau canReview == true)
                    if (canReview) ...[
                      const SizedBox(height: 20),
                      const Text(
                        "Tulis Review Anda",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 30,
                            ),
                            onPressed: () =>
                                setState(() => selectedRating = index + 1),
                          );
                        }),
                      ),
                      TextField(
                        controller: reviewController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Tulis ulasan...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: // Di UI (DetailBengkelScreen), tombol submit
                        ElevatedButton(
                          onPressed: () async {
                            if (storeDetail!.services.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Tidak ada service untuk direview",
                                  ),
                                ),
                              );
                              return;
                            }

                            final serviceId = storeDetail!.services[0].id;

                            final newReviewJson =
                                await StoreService.submitReview(
                                  storeId: storeDetail!.id,
                                  serviceId: serviceId,
                                  rate: selectedRating,
                                  message: reviewController.text,
                                );

                            if (newReviewJson != null) {
                              final newReview = ReviewModel.fromJson(
                                newReviewJson,
                              );

                              setState(() {
                                storeDetail!.reviews.insert(
                                  0,
                                  newReview,
                                ); // tambah paling atas
                                selectedRating = 0;
                                reviewController.clear();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Review berhasil dikirim"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Gagal mengirim review"),
                                ),
                              );
                            }
                          },
                          child: const Text("KIRIM"),
                        ),
                      ),
                    ],
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

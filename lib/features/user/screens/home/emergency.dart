import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/user/widgets/start_rating.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart'; // jangan lupa tambahkan package ini di pubspec.yaml

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final Dio _dio = Dio();
  final box = GetStorage();

  List<StoreModel> allStores = [];
  bool _loading = true;
  String _errorMessage = '';

  List<StoreModel> get emergencyStores =>
      allStores.where((store) => store.emergencyCall == true).toList();

  @override
  void initState() {
    super.initState();
    _fetchAllStores();
  }

  Future<String> _getToken() async {
    return box.read('token') ?? '';
  }

  Future<void> _fetchAllStores() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final token = await _getToken();
      if (token.isEmpty) {
        setState(() {
          _errorMessage = 'Token belum tersedia, coba login ulang.';
          _loading = false;
        });
        return;
      }

      final response = await _dio.getUri(
        ApiBase.uri('store'),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        allStores = data.map((e) => StoreModel.fromJson(e)).toList();
      } else {
        setState(() {
          _errorMessage =
              'Error: ${response.statusCode} - ${response.statusMessage}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildBengkelCard(StoreModel store) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routers.detailbengkel, arguments: store.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: store.image != null && store.image!.isNotEmpty
                  ? Image.network(
                      '${ApiBase.imageUrl}${store.image}', // gabungkan base url + path gambar
                      width: 100,

                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/banner.png',
                          width: 100,
                          height: 65,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/banner.png',
                      width: 100,
                      height: 65,
                    ),
            ),
            const SizedBox(width: 12),
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
                        fontSize: 12,
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
                            fontSize: 10,
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
                          size: 10,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            store.address ?? 'Alamat tidak tersedia',
                            style: const TextStyle(
                              fontSize: 12,
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
            Transform.translate(
              offset: const Offset(
                -10,
                0,
              ), // geser seluruh container 10 pixel ke kiri
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // buat bulat
                  color: Colors.redAccent, // warna latar
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Transform.translate(
                    offset: const Offset(
                      -1,
                      0,
                    ), // geser icon sedikit ke kiri di dalam bulatan
                    child: const Icon(Icons.call, color: Colors.white),
                  ),
                  onPressed: () async {
                    final phone = store.contact ?? '';
                    if (phone.isNotEmpty) {
                      final whatsappUrl = Uri.parse("https://wa.me/$phone");
                      if (await canLaunchUrl(whatsappUrl)) {
                        await launchUrl(
                          whatsappUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
                      }
                    } else {
                      Get.snackbar('Info', 'Nomor telepon tidak tersedia');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(body: Center(child: Text(_errorMessage)));
    }

    if (emergencyStores.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada bengkel emergency')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Bengkel',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: emergencyStores.length,
        itemBuilder: (context, index) {
          final store = emergencyStores[index];
          return _buildBengkelCard(store);
        },
      ),
    );
  }
}

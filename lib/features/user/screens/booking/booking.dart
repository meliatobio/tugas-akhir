import 'dart:async';
import 'dart:convert';
import 'package:bengkel/app/routers.dart';
import 'package:bengkel/constants/api_base.dart';
import 'package:bengkel/features/user/widgets/start_rating.dart';
import 'package:bengkel/shared/widgets/wave_backround.dart';
import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final box = GetStorage();
  List<StoreModel> searchResults = [];
  bool isLoading = false;
  bool showFilter = false;
  String? selectedVehicleType;
  bool sortByRating = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchAllStores();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAllStores() async {
    final token = box.read('token');
    final url = Uri.parse('${ApiBase.baseUrl}store');

    setState(() => isLoading = true);

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
          searchResults = data.map((e) => StoreModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          searchResults = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetch stores: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> searchStore(String keyword) async {
    final token = box.read('token');
    final url = Uri.parse('${ApiBase.baseUrl}store');

    setState(() => isLoading = true);

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

        // Mapping ke StoreModel dulu supaya bisa akses services
        final stores = data.map((e) => StoreModel.fromJson(e)).toList();

        // Filter berdasarkan service name
        final filtered = stores.where((store) {
          return store.services.any(
            (service) =>
                service.name.toLowerCase().contains(keyword.toLowerCase()),
          );
        }).toList();

        setState(() {
          searchResults = filtered;
          isLoading = false;
        });
      } else {
        setState(() {
          searchResults = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error search: $e");
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        fetchAllStores();
      } else {
        searchStore(query.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          ClipPath(
            clipper: BookingWaveClipper2(),
            child: Container(height: 120, color: Colors.yellow.shade200),
          ),
          ClipPath(
            clipper: BookingWaveClipper1(),
            child: Container(height: 100, color: Colors.amber),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    "Booking",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      hintText: "Cari Bengkel...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            showFilter = !showFilter;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : searchResults.isEmpty
                      ? const Center(child: Text('Bengkel tidak ditemukan'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: searchResults.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final store = searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  Routers.detailbengkel,
                                  arguments: store.id,
                                );
                              },
                              child: _buildBengkelCard(store),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (showFilter) _buildFilterOverlay(),
        ],
      ),
    );
  }

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
                        fontSize: 15,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(77),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jenis Kendaraan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("Motor"),
                        selected: selectedVehicleType == "motor",
                        onSelected: (selected) {
                          setState(() {
                            selectedVehicleType = selected ? "motor" : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Mobil"),
                        selected: selectedVehicleType == "mobil",
                        onSelected: (selected) {
                          setState(() {
                            selectedVehicleType = selected ? "mobil" : null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Urutkan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ChoiceChip(
                    label: const Text("Rating Tertinggi"),
                    selected: sortByRating,
                    onSelected: (selected) {
                      setState(() {
                        sortByRating = selected;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              var filtered = List.from(searchResults);
                              if (selectedVehicleType != null) {
                                filtered = filtered.where((store) {
                                  return (store.acceptedVehicleTypes ?? [])
                                      .contains(selectedVehicleType);
                                }).toList();
                              }
                              if (sortByRating) {
                                filtered.sort(
                                  (a, b) =>
                                      (b.rating ?? 0).compareTo(a.rating ?? 0),
                                );
                              }
                              searchResults = filtered.cast<StoreModel>();
                              showFilter = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("Pakai"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedVehicleType = null;
                              sortByRating = false;
                              fetchAllStores();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("Reset"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

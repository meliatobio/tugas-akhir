import 'package:bengkel/features/owner/screens/riwayat/detail_kelola_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bengkel/features/owner/services/store_service.dart';
import 'package:bengkel/models/booking_model.dart';

// 🔹 Wave Clipper
class BookingWaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height - 10);
    var firstEndPoint = Offset(size.width / 2, size.height - 25);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 40);
    var secondEndPoint = Offset(size.width, size.height - 5);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BookingWaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 35);
    var secondEndPoint = Offset(size.width, size.height - 8);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// 🔹 Kelola Booking Screen
class KelolaBookingScreen extends StatefulWidget {
  const KelolaBookingScreen({super.key});

  @override
  State<KelolaBookingScreen> createState() => _KelolaBookingScreenState();
}

class _KelolaBookingScreenState extends State<KelolaBookingScreen> {
  final StoreService _storeService = StoreService();
  List<BookingModel> bookings = [];
  List<BookingModel> filteredBookings = [];
  Map<int, String> storeNames = {};
  int? selectedStoreId;
  String? selectedStatus;
  bool newestFirst = true;
  bool isLoading = true;
  bool showFilter = false; // untuk overlay filter

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      final data = await _storeService.fetchBookingsForOwner();
      final Map<int, String> map = {for (var b in data) b.storeId: b.storeName};

      setState(() {
        bookings = data;
        filteredBookings = List.from(bookings);
        storeNames = map;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    List<BookingModel> temp = List.from(bookings);
    if (selectedStoreId != null) {
      temp = temp.where((b) => b.storeId == selectedStoreId).toList();
    }
    if (selectedStatus != null) {
      temp = temp
          .where((b) => b.status.toLowerCase() == selectedStatus!.toLowerCase())
          .toList();
    }
    temp.sort((a, b) {
      final dateA = DateTime.parse('${a.bookingDate} ${a.bookingTime}');
      final dateB = DateTime.parse('${b.bookingDate} ${b.bookingTime}');
      return newestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    setState(() => filteredBookings = temp);
  }

  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red, size: 20);
      case 'pending':
        return const Icon(Icons.access_time, color: Colors.orange, size: 20);
      case 'completed':
        return const Icon(Icons.check, color: Colors.blue, size: 20);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 20);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // 🔹 Wave Background
          ClipPath(
            clipper: BookingWaveClipper2(),
            child: Container(height: 120, color: Colors.yellow.shade200),
          ),
          ClipPath(
            clipper: BookingWaveClipper1(),
            child: Container(height: 100, color: Colors.amber),
          ),

          // 🔹 Konten Utama
          SafeArea(
            child: Column(
              children: [
                // Transparent AppBar
                AppBar(
                  title: const Text(
                    "Kelola Booking",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          showFilter = true;
                        });
                      },
                    ),
                  ],
                ),

                // 🔹 List Booking
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredBookings.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada booking dari customer.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadBookings,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final item = filteredBookings[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Get.to(
                                    () => DetailKelolaScreen(transaction: item),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.storeName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(
                                                item.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                getStatusIcon(item.status),
                                                Center(
                                                  child: Text(
                                                    item
                                                            .status
                                                            .capitalizeFirst ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.build,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item.serviceName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${item.bookingDate} ${item.bookingTime}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.monetization_on,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Rp${item.totalPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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

          // 🔹 Overlay Filter
          if (showFilter)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(77),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pilih Bengkel",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: storeNames.entries.map((entry) {
                              return ChoiceChip(
                                label: Text(entry.value),
                                selected: selectedStoreId == entry.key,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedStoreId = selected
                                        ? entry.key
                                        : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Pilih Status",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 9, // jarak horizontal antar chip
                            runSpacing: 8, // jarak vertikal antar baris chip
                            children:
                                [
                                  'pending',
                                  'confirmed',
                                  'completed',
                                  'cancelled',
                                ].map((s) {
                                  return ChoiceChip(
                                    label: Text(s.capitalizeFirst!),
                                    selected: selectedStatus == s,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedStatus = selected ? s : null;
                                      });
                                    },
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    applyFilter();
                                    setState(() => showFilter = false);
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
                                      selectedStoreId = null;
                                      selectedStatus = null;
                                      applyFilter();
                                    });
                                  },
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
            ),
        ],
      ),
    );
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
      return Colors.green;
    case 'completed':
      return Colors.blue;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

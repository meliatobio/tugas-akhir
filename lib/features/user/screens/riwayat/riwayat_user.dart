import 'package:bengkel/models/booking_model.dart';
import 'package:bengkel/services/booking_services.dart';
import 'package:flutter/material.dart';
import 'detail_transaksi_screen.dart';

class RiwayatWaveClipper1 extends CustomClipper<Path> {
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

class RiwayatWaveClipper2 extends CustomClipper<Path> {
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

class RiwayatUserScreen extends StatefulWidget {
  const RiwayatUserScreen({super.key});

  @override
  State<RiwayatUserScreen> createState() => _RiwayatUserScreenState();
}

class _RiwayatUserScreenState extends State<RiwayatUserScreen> {
  late Future<List<BookingModel>> _bookingFuture;
  List<BookingModel> _allBookings = [];
  List<BookingModel> _filteredBookings = [];

  String? selectedVehicleType;
  String? selectedStatus;
  bool sortNewestFirst = true;
  bool showFilterOverlay = false;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _loadBookings();
  }

  Future<List<BookingModel>> _loadBookings() async {
    final data = await BookingService.fetchUserBookings();
    _allBookings = data;
    _filteredBookings = List.from(_allBookings);

    // ✅ Debug log biar kelihatan isi data
    for (var b in _allBookings) {
      debugPrint("Booking ID: ${b.id}");
      debugPrint("  Store: ${b.storeName}");
      debugPrint("  Service: ${b.serviceName}");
      debugPrint("  Status: ${b.status}");
      debugPrint("  Tanggal: ${b.bookingDate} ${b.bookingTime}");
      debugPrint("-------------------------------");
    }

    return data;
  }

  void _applyFilters() {
    var filtered = List<BookingModel>.from(_allBookings);

    if (selectedVehicleType != null) {
      filtered = filtered
          .where(
            (b) =>
                b.vehicleType.toLowerCase() ==
                selectedVehicleType!.toLowerCase(),
          )
          .toList();
    }

    if (selectedStatus != null) {
      filtered = filtered
          .where((b) => b.status.toLowerCase() == selectedStatus!.toLowerCase())
          .toList();
    }

    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a.bookingDate) ?? DateTime(2000);
      final dateB = DateTime.tryParse(b.bookingDate) ?? DateTime(2000);
      return sortNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    setState(() {
      _filteredBookings = filtered;
      showFilterOverlay = false;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedVehicleType = null;
      selectedStatus = null;
      sortNewestFirst = true;
      _filteredBookings = List.from(_allBookings);
      showFilterOverlay = true; // tetap overlay agar chip rebuild
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _bookingFuture = _loadBookings();
    });
    await _bookingFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          ClipPath(
            clipper: RiwayatWaveClipper2(),
            child: Container(height: 120, color: Colors.yellow.shade200),
          ),
          ClipPath(
            clipper: RiwayatWaveClipper1(),
            child: Container(height: 100, color: Colors.amber),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Riwayat Transaksi",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          setState(() {
                            showFilterOverlay = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<BookingModel>>(
                    future: _bookingFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Gagal memuat data: ${snapshot.error}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      if (_filteredBookings.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ada data yang sesuai filter.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            final item = _filteredBookings[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailTransaksiScreen(
                                      bookingId: item.id,
                                      onBackToRiwayat: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/dashboard',
                                          arguments: {'tab': 2},
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nama bengkel + status sejajar
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.storeName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(item.status),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            item.status.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    Text(
                                      'Layanan: ${item.serviceName}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.blueGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.bookingDate,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Rp${item.totalPrice}',
                                          style: const TextStyle(
                                            fontSize: 14,
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (showFilterOverlay) _buildFilterOverlay(),
        ],
      ),
    );
  }

  Widget _buildFilterOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(78),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Status Booking",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ChoiceChip(
                        label: const Text("Pending"),
                        selected: selectedStatus == "pending",
                        onSelected: (selected) => setState(
                          () => selectedStatus = selected ? "pending" : null,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text("Confirmed"),
                        selected: selectedStatus == "confirmed",
                        onSelected: (selected) => setState(
                          () => selectedStatus = selected ? "confirmed" : null,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text("Completed"),
                        selected: selectedStatus == "completed",
                        onSelected: (selected) => setState(
                          () => selectedStatus = selected ? "completed" : null,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text("Cancelled"),
                        selected: selectedStatus == "cancelled",
                        onSelected: (selected) => setState(
                          () => selectedStatus = selected ? "cancelled" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Pakai",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Reset",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  // Helper function warna status
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
}

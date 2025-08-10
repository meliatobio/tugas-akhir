import 'package:bengkel/models/booking_model.dart';
import 'package:bengkel/services/booking_services.dart';
import 'package:flutter/material.dart';
import 'detail_transaksi_screen.dart';

// Wave kuning tua (atas) - versi riwayat
class RiwayatWaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40); // kiri tinggi
    var firstControlPoint = Offset(size.width / 4, size.height - 10);
    var firstEndPoint = Offset(size.width / 2, size.height - 25);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 40);
    var secondEndPoint = Offset(size.width, size.height - 5); // kanan rendah
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

// Wave kuning pucat (bawah) - versi riwayat
class RiwayatWaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20); // kiri tinggi
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 35);
    var secondEndPoint = Offset(size.width, size.height - 8); // kanan rendah
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

  @override
  void initState() {
    super.initState();
    _bookingFuture = BookingService.fetchUserBookings();
  }

  Future<void> _refreshData() async {
    setState(() {
      _bookingFuture = BookingService.fetchUserBookings();
    });
    await _bookingFuture;
  }

  Icon getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'ditolak':
        return const Icon(Icons.cancel, color: Colors.red, size: 20);
      case 'menunggu':
        return const Icon(Icons.access_time, color: Colors.orange, size: 20);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Wave kuning pucat (bawah)
          ClipPath(
            clipper: RiwayatWaveClipper2(),
            child: Container(height: 120, color: Colors.yellow.shade200),
          ),
          // Wave kuning tua (atas)
          ClipPath(
            clipper: RiwayatWaveClipper1(),
            child: Container(height: 100, color: Colors.amber),
          ),

          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    "Riwayat Transaksi",
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

                      final bookings = snapshot.data ?? [];

                      if (bookings.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada riwayat transaksi.',
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
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final item = bookings[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailTransaksiScreen(
                                      transaction: item.toMap(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.vehicleType,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        getStatusIcon(item.status),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Status: ${item.status}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tanggal: ${item.bookingDate}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Total: Rp${item.totalPrice}',
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
        ],
      ),
    );
  }
}

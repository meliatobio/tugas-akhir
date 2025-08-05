import 'package:flutter/material.dart';
import 'detail_transaksi_screen.dart';

class RiwayatOwnerScreen extends StatelessWidget {
  const RiwayatOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyTransactions = [
      {
        "id": "1",
        "jenisKendaraan": "Motor",
        "status": "Diterima",
        "tanggal": "21 Juni 2025",
        "jam": "09:00",
        "noPol": "BA 1234 CD",
        "layanan": "Servis Ringan",
        "dp": 10000,
        "totalHarga": 50000,
        "rekening": "1234567890 - BCA",
      },
      {
        "id": "2",
        "jenisKendaraan": "Mobil",
        "status": "Menunggu",
        "tanggal": "20 Juni 2025",
        "jam": "13:30",
        "noPol": "BA 5678 EF",
        "layanan": "Ganti Oli",
        "dp": 20000,
        "totalHarga": 120000,
        "rekening": "0987654321 - Mandiri",
      },
      {
        "id": "3",
        "jenisKendaraan": "Motor",
        "status": "Ditolak",
        "tanggal": "18 Juni 2025",
        "jam": "11:00",
        "noPol": "BA 9999 ZZ",
        "layanan": "Cuci Steam",
        "dp": 0,
        "totalHarga": 0,
        "rekening": "Belum tersedia",
      },
    ];

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: dummyTransactions.isEmpty
          ? Center(
              child: Text(
                'Belum ada riwayat transaksi.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dummyTransactions.length,
              itemBuilder: (context, index) {
                final item = dummyTransactions[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailTransaksiScreen(transaction: item),
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
                          item['jenisKendaraan'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            getStatusIcon(item['status']),
                            const SizedBox(width: 6),
                            Text(
                              'Status: ${item['status']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tanggal: ${item['tanggal']}',
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
                              'Total: Rp${item['totalHarga']}',
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
  }
}

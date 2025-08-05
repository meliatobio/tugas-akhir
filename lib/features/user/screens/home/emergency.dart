import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  final List<Map<String, dynamic>> dummyBengkel = const [
    {
      'nama': 'Bengkel Andalas',
      'rating': 4.5,
      'kontak': '081234567890',
      'alamat': 'Jl. Merdeka No. 10, Padang',
    },
    {
      'nama': 'Bengkel Jaya Motor',
      'rating': 4.0,
      'kontak': '082233445566',
      'alamat': 'Jl. Veteran No. 5, Bukittinggi',
    },
    {
      'nama': 'Bengkel AutoCare',
      'rating': 4.8,
      'kontak': '083312345678',
      'alamat': 'Jl. Sudirman No. 20, Padang Panjang',
    },
  ];

  void _openWhatsApp(String phoneNumber) async {
    final url = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Gagal membuka WhatsApp
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emergency Call",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyBengkel.length,
        itemBuilder: (context, index) {
          final bengkel = dummyBengkel[index];
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 24, right: 50),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bengkel['nama'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(bengkel['rating'].toString()),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16),
                        const SizedBox(width: 4),
                        Text(bengkel['kontak']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(bengkel['alamat'])),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.phone_in_talk_rounded,
                    color: Colors.green,
                    size: 32,
                  ),
                  onPressed: () => _openWhatsApp(bengkel['kontak']),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

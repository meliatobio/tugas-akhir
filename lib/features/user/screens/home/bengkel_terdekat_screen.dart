import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BengkelTerdekatScreen extends StatelessWidget {
  const BengkelTerdekatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data bengkel dengan jarak
    final List<Map<String, dynamic>> bengkelList = [
      {
        "name": "Bengkel Otto",
        "address": "Jl. Merdeka No. 10",
        "rating": 4.5,
        "distance": 0.8, // dalam KM
      },
      {
        "name": "Bengkel Maju Jaya",
        "address": "Jl. Sudirman No. 25",
        "rating": 4.2,
        "distance": 1.2,
      },
      {
        "name": "Bengkel SpeedTech",
        "address": "Jl. Gajah Mada No. 7",
        "rating": 4.7,
        "distance": 0.5,
      },
    ];

    // Urutkan berdasarkan jarak terdekat
    bengkelList.sort((a, b) => a['distance'].compareTo(b['distance']));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Row(
          children: [
            Icon(Icons.place, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              "Bengkel Terdekat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bengkelList.length,
        itemBuilder: (context, index) {
          final bengkel = bengkelList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(
                Icons.home_repair_service,
                color: Colors.orange,
              ),
              title: Text(
                bengkel['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bengkel['address']),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(bengkel['rating'].toString()),
                      const SizedBox(width: 12),
                      const Icon(Icons.directions_walk, size: 16),
                      const SizedBox(width: 4),
                      Text("${bengkel['distance']} KM"),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // Navigasi ke detail bengkel
                Get.toNamed('/detailbengkel');
              },
            ),
          );
        },
      ),
    );
  }
}

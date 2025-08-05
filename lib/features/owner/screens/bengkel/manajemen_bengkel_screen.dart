import 'package:bengkel/models/bengkel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManajemenBengkelScreen extends StatefulWidget {
  final StoreModel store;

  const ManajemenBengkelScreen({super.key, required this.store});

  @override
  State<ManajemenBengkelScreen> createState() => _ManajemenBengkelScreenState();
}

class _ManajemenBengkelScreenState extends State<ManajemenBengkelScreen> {
  bool isEmergencyOn = true;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Bengkel'),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          iconSize: 24, // kecilkan ukuran
        ),
      ),

      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/banner.png',
            width: double.infinity,
            height: 280,
            fit: BoxFit.cover,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(16),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      store.storeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(store.address ?? 'Alamat tidak tersedia'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Jam Operasional : ${store.openAt} - ${store.closeAt} WIB',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Kontak : ${store.contact ?? "-"} (${store.contactName ?? "-"})',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.directions_car, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Kendaraan: ${store.acceptedVehicleTypes.join(', ')}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/maps.png'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Emergency logic
                          },
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: const Text('Emergency Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text("ON"),
                        Switch(
                          value: isEmergencyOn,
                          onChanged: (value) {
                            setState(() => isEmergencyOn = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Layanan Aktif:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    store.services.isEmpty
                        ? const Text("Belum ada layanan terdaftar.")
                        : Column(
                            children: store.services.map((service) {
                              return ListTile(
                                title: Text(service.name),
                                subtitle: Text(service.description),
                                trailing: Text(
                                  'Rp ${service.price.toStringAsFixed(0)}',
                                ),
                              );
                            }).toList(),
                          ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Tambah layanan
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      label: const Text('Tambah Layanan'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ulasan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    store.reviews.isEmpty
                        ? const Text("Belum ada ulasan.")
                        : Column(
                            children: store.reviews.map((review) {
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(
                                          review.rating,
                                          (index) => const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('"${review.comment}"'),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Aksi balas ulasan
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                    ),
                                    child: const Text('Balas'),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

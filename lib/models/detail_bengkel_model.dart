import 'service_model.dart';
import 'review_model.dart';

class DetailStoreModel {
  final String storeName;
  final String address;
  final String contact;
  final String contactName;
  final double long;
  final double lat;
  final String openAt;
  final String closeAt;
  final List<String> acceptedVehicleTypes;
  final List<ServiceModel> services;
  final List<ReviewModel> reviews;

  // ✅ Tambahan field dummy
  final double rating;
  final double distance;

  DetailStoreModel({
    required this.storeName,
    required this.address,
    required this.contact,
    required this.contactName,
    required this.long,
    required this.lat,
    required this.openAt,
    required this.closeAt,
    required this.acceptedVehicleTypes,
    required this.services,
    required this.reviews,
    required this.rating,
    required this.distance,
  });

  factory DetailStoreModel.fromJson(Map<String, dynamic> json) {
    final info = json['store_info'] ?? {};

    return DetailStoreModel(
      storeName: info['store_name'] ?? '',
      address: info['address'] ?? '',
      contact: info['contact'] ?? '',
      contactName: info['contact_name'] ?? '',
      long: double.tryParse(info['long'].toString()) ?? 0.0,
      lat: double.tryParse(info['lat'].toString()) ?? 0.0,
      openAt: info['open_at'] ?? '',
      closeAt: info['close_at'] ?? '',
      acceptedVehicleTypes: List<String>.from(
        info['accepted_vehicle_types'] ?? [],
      ),
      services: (json['store_service'] ?? [])
          .map<ServiceModel>((e) => ServiceModel.fromJson(e))
          .toList(),
      reviews: (json['store_review'] ?? [])
          .map<ReviewModel>((e) => ReviewModel.fromJson(e))
          .toList(),

      // ✅ Dummy values
      rating: 4.6,
      distance: 2.3,
    );
  }
}

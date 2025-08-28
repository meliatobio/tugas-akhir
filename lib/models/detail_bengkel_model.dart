import 'service_model.dart';
import 'review_model.dart';

class DetailStoreModel {
  final int id;
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
  final double rating;
  final double distance;
  final String? image; // field baru, opsional

  DetailStoreModel({
    required this.id,
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
    this.image, // opsional
  });

  factory DetailStoreModel.fromJson(Map<String, dynamic> json) {
    final info = json['store_info'] ?? {};
    final coordinate = info['coordinate'] ?? {};

    return DetailStoreModel(
      id: info['id'] ?? 0,
      storeName: info['store_name'] ?? '',
      address: info['address'] ?? '',
      contact: info['contact'] ?? '',
      contactName: info['contact_name'] ?? '',
      lat: double.tryParse(coordinate['lat']?.toString() ?? '0') ?? 0.0,
      long: double.tryParse(coordinate['long']?.toString() ?? '0') ?? 0.0,
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
      rating:
          double.tryParse(
            info['summary']?['average_rating']?.toString() ?? '0',
          ) ??
          0.0,
      distance: 0.0,
      image: info['image'], // mapping image dari JSON
    );
  }
}

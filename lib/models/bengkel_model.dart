import 'dart:convert';

import 'package:bengkel/models/review_model.dart';
import 'package:bengkel/models/service_model.dart';
import 'package:flutter/material.dart';

class StoreModel {
  final int id;
  final int userId;
  final String storeName;
  final String? address;
  final String? contact;
  final String? contactName;
  final String? image;
  final double? long;
  final double? lat;
  final String? openAt;
  final String? closeAt;
  final List<String> acceptedVehicleTypes;
  final double? rating;
  final List<ServiceModel> services;
  final List<ReviewModel> reviews;
  final String? photo;
  final bool isActive;
  final bool emergencyCall; // ✅ field baru

  StoreModel({
    required this.id,
    required this.userId,
    required this.storeName,
    this.address,
    this.contact,
    this.contactName,
    this.image,
    this.long,
    this.lat,
    this.openAt,
    this.closeAt,
    this.acceptedVehicleTypes = const [],
    this.rating,
    this.services = const [],
    this.reviews = const [],
    this.photo,
    required this.isActive,
    this.emergencyCall = false, // ✅ default aman
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 Store JSON: ${jsonEncode(json)}');

    return StoreModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? -1,
      userId: json['user_id'] ?? 0,
      storeName: json['store_name'] ?? '',
      address: json['address'],
      contact: json['contact'],
      contactName: json['contact_name'],
      image: json['image'],
      long: json['long'] != null
          ? double.tryParse(json['long'].toString())
          : null,
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      openAt: json['open_at'],
      closeAt: json['close_at'],
      acceptedVehicleTypes:
          (json['accepted_vehicle_types'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString())
          : null,
      services: json['services'] != null
          ? List<ServiceModel>.from(
              json['services'].map((x) => ServiceModel.fromJson(x)),
            )
          : [],
      reviews: json['reviews'] != null
          ? List<ReviewModel>.from(
              json['reviews'].map((x) => ReviewModel.fromJson(x)),
            )
          : [],
      photo: 'https://via.placeholder.com/150',
      isActive: json['is_active'] ?? true,
      emergencyCall: json['emergency_call'] ?? false, // ✅ ambil dari API
    );
  }

  StoreModel copyWith({
    int? id,
    int? userId,
    String? storeName,
    String? address,
    String? contact,
    String? contactName,
    String? image,
    double? long,
    double? lat,
    String? openAt,
    String? closeAt,
    List<String>? acceptedVehicleTypes,
    double? rating,
    List<ServiceModel>? services,
    List<ReviewModel>? reviews,
    String? photo,
    bool? isActive,
    bool? emergencyCall,
  }) {
    return StoreModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      contactName: contactName ?? this.contactName,
      image: image ?? this.image,
      long: long ?? this.long,
      lat: lat ?? this.lat,
      openAt: openAt ?? this.openAt,
      closeAt: closeAt ?? this.closeAt,
      acceptedVehicleTypes: acceptedVehicleTypes ?? this.acceptedVehicleTypes,
      rating: rating ?? this.rating,
      services: services ?? this.services,
      reviews: reviews ?? this.reviews,
      photo: photo ?? this.photo,
      isActive: isActive ?? this.isActive,
      emergencyCall: emergencyCall ?? this.emergencyCall,
    );
  }
}

// import 'dart:convert';

// import 'package:flutter/material.dart';

// import 'service_model.dart';
// import 'review_model.dart';

// class StoreModel {
//   final int id;
//   final int userId;
//   final String storeName;
//   final String? address;
//   final String? contact;
//   final String? contactName;
//   final String? image;
//   final double? long;
//   final double? lat;
//   final String? openAt;
//   final String? closeAt;
//   final List<String> acceptedVehicleTypes;
//   final double? rating;
//   final List<ServiceModel> services;
//   final List<ReviewModel> reviews;
//   final String? photo;
//   final bool isActive;

//   StoreModel({
//     required this.id,
//     required this.userId,
//     required this.storeName,
//     this.address,
//     this.contact,
//     this.contactName,
//     this.image,
//     this.long,
//     this.lat,
//     this.openAt,
//     this.closeAt,
//     this.acceptedVehicleTypes = const [],
//     this.rating,
//     this.services = const [],
//     this.reviews = const [],
//     this.photo,
//     required this.isActive,
//   });

//   factory StoreModel.fromJson(Map<String, dynamic> json) {
//     debugPrint('📦 Store JSON: ${jsonEncode(json)}');

//     return StoreModel(
//       id: json['id'] is int
//           ? json['id']
//           : int.tryParse(json['id'].toString()) ?? -1,
//       userId: json['user_id'] ?? 0,
//       storeName: json['store_name'] ?? '',
//       address: json['address'],
//       contact: json['contact'],
//       contactName: json['contact_name'],
//       image: json['image'],
//       long: json['long'] != null
//           ? double.tryParse(json['long'].toString())
//           : null,
//       lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
//       openAt: json['open_at'],
//       closeAt: json['close_at'],
//       acceptedVehicleTypes:
//           (json['accepted_vehicle_types'] as List?)
//               ?.map((e) => e.toString())
//               .toList() ??
//           [],

//       rating: (json['rating'] != null)
//           ? double.tryParse(json['rating'].toString())
//           : null,
//       services: json['services'] != null
//           ? List<ServiceModel>.from(
//               json['services'].map((x) => ServiceModel.fromJson(x)),
//             )
//           : [],
//       reviews: json['reviews'] != null
//           ? List<ReviewModel>.from(
//               json['reviews'].map((x) => ReviewModel.fromJson(x)),
//             )
//           : [],
//       photo: 'https://via.placeholder.com/150', // contoh foto dummy
//       isActive: true,
//     );
//   }

//   /// ✅ Tambahkan copyWith
//   StoreModel copyWith({
//     int? id,
//     int? userId,
//     String? storeName,
//     String? address,
//     String? contact,
//     String? contactName,
//     String? image,
//     double? long,
//     double? lat,
//     String? openAt,
//     String? closeAt,
//     List<String>? acceptedVehicleTypes,
//     double? rating,
//     List<ServiceModel>? services,
//     List<ReviewModel>? reviews,
//     String? photo,
//     bool? isActive,
//   }) {
//     return StoreModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       storeName: storeName ?? this.storeName,
//       address: address ?? this.address,
//       contact: contact ?? this.contact,
//       contactName: contactName ?? this.contactName,
//       image: image ?? this.image,
//       long: long ?? this.long,
//       lat: lat ?? this.lat,
//       openAt: openAt ?? this.openAt,
//       closeAt: closeAt ?? this.closeAt,
//       acceptedVehicleTypes: acceptedVehicleTypes ?? this.acceptedVehicleTypes,
//       rating: rating ?? this.rating,
//       services: services ?? this.services,
//       reviews: reviews ?? this.reviews,
//       photo: photo ?? this.photo,
//       isActive: isActive ?? this.isActive,
//     );
//   }
// }

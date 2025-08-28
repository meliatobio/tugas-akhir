import 'dart:convert';
import 'service_model.dart';
import 'review_model.dart';
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
  List<ServiceModel> services;
  final List<ReviewModel> reviews;
  final String? photo;
  final bool active;
  final bool emergencyCall;

  // ✅ tambahan
  final bool userHasBooking;
  final bool userHasReview;

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
    required this.active,
    this.emergencyCall = false,
    this.userHasBooking = false, // default false
    this.userHasReview = false, // default false
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 Store JSON: ${jsonEncode(json)}');

    // Fallback key mapping
    if (json['services'] == null && json['store_service'] != null) {
      json['services'] = json['store_service'];
    }
    if (json['reviews'] == null && json['review'] != null) {
      json['reviews'] = json['review'];
    }

    // Ambil rating
    double? ratingValue;
    if (json['summary']?['average_rating'] != null) {
      ratingValue = double.tryParse(
        json['summary']['average_rating'].toString(),
      );
    } else if (json['reviews'] != null &&
        (json['reviews'] as List).isNotEmpty) {
      var reviewsList = json['reviews'] as List;
      ratingValue =
          reviewsList.map((r) => r['rate'] as num).reduce((a, b) => a + b) /
          reviewsList.length;
    }

    // Parsing koordinat
    double? latValue;
    double? longValue;
    try {
      var latRaw = json['coordinate']?['lat'];
      var longRaw = json['coordinate']?['long'];
      debugPrint('🔍 Raw coordinate data: lat=$latRaw, long=$longRaw');

      if (latRaw != null) latValue = double.tryParse(latRaw.toString());
      if (longRaw != null) longValue = double.tryParse(longRaw.toString());

      if (latValue == null || latValue < -90 || latValue > 90) {
        debugPrint('❌ Latitude invalid: $latValue');
        latValue = null;
      }
      if (longValue == null || longValue < -180 || longValue > 180) {
        debugPrint('❌ Longitude invalid: $longValue');
        longValue = null;
      }

      debugPrint('✅ Validated coordinate: lat=$latValue, long=$longValue');
    } catch (e) {
      debugPrint('❌ Error parsing coordinate: $e');
      latValue = null;
      longValue = null;
    }

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
      lat: latValue,
      long: longValue,
      openAt: json['open_at'],
      closeAt: json['close_at'],
      acceptedVehicleTypes:
          (json['accepted_vehicle_types'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: ratingValue,
      services: json['services'] != null
          ? List<ServiceModel>.from(
              json['services'].map(
                (x) => ServiceModel.fromJson({
                  ...x,
                  'vehicle_type': x['vehicle_type'] is String
                      ? jsonDecode(x['vehicle_type'])
                      : x['vehicle_type'],
                }),
              ),
            )
          : [],
      reviews: json['reviews'] != null
          ? List<ReviewModel>.from(
              json['reviews'].map((x) => ReviewModel.fromJson(x)),
            )
          : [],
      photo: 'https://via.placeholder.com/150',
      active: json['active'] ?? false,
      emergencyCall: json['emergency_call'] ?? false,

      // ✅ ambil dari backend kalau ada, fallback false
      userHasBooking: json['user_has_booking'] ?? false,
      userHasReview: json['user_has_review'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'address': address,
      'contact': contact,
      'contact_name': contactName,
      'image': image,
      'long': long,
      'lat': lat,
      'open_at': openAt,
      'close_at': closeAt,
      'accepted_vehicle_types': acceptedVehicleTypes,
      'rating': rating,
      'services': services.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'photo': photo,
      'active': active,
      'emergency_call': emergencyCall,
      'user_has_booking': userHasBooking,
      'user_has_review': userHasReview,
    };
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
    bool? active,
    bool? emergencyCall,
    bool? userHasBooking,
    bool? userHasReview,
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
      active: active ?? this.active,
      emergencyCall: emergencyCall ?? this.emergencyCall,
      userHasBooking: userHasBooking ?? this.userHasBooking,
      userHasReview: userHasReview ?? this.userHasReview,
    );
  }

  void addServiceToStore(ServiceModel service) {
    services = [...services, service];
  }
}

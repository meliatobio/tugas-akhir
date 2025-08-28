import 'dart:convert';

class ServiceModel {
  final int id;
  final int storeId;
  final String name;
  final String description;
  List<String> vehicleType; // 🔹 sudah mutable
  final int price;

  ServiceModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.vehicleType,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      vehicleType: (json['vehicle_type'] is String
          ? List<String>.from(jsonDecode(json['vehicle_type']))
          : (json['vehicle_type'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                []),
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'vehicle_type': jsonEncode(vehicleType),
      'price': price,
    };
  }
}

// import 'dart:convert';

// class ServiceModel {
//   final int id;
//   final int storeId;
//   final String name;
//   final String description;
//   final List<String> vehicleType;
//   final int price;

//   ServiceModel({
//     required this.id,
//     required this.storeId,
//     required this.name,
//     required this.description,
//     required this.vehicleType,
//     required this.price,
//   });

//   factory ServiceModel.fromJson(Map<String, dynamic> json) {
//     return ServiceModel(
//       id: json['id'] ?? 0,
//       storeId: json['store_id'] ?? 0,
//       name: json['name'] ?? 'Unknown',
//       description: json['description'] ?? '',
//       vehicleType: (json['vehicle_type'] is String
//           ? List<String>.from(jsonDecode(json['vehicle_type']))
//           : (json['vehicle_type'] as List?)
//                     ?.map((e) => e.toString())
//                     .toList() ??
//                 []),
//       price: json['price'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'store_id': storeId,
//       'name': name,
//       'description': description,
//       'vehicle_type': jsonEncode(vehicleType), // ✅ Kirim sebagai string JSON
//       'price': price,
//     };
//   }
// }

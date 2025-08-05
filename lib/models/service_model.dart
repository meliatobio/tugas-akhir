class ServiceModel {
  final String name;
  final String description;
  final String vehicleType;
  final int price;

  ServiceModel({
    required this.name,
    required this.description,
    required this.vehicleType,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}

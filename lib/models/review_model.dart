class ReviewModel {
  final int id;
  final int storeId;
  final int serviceId;
  final int userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.storeId,
    required this.serviceId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      storeId: json['store_id'],
      serviceId: json['service_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Anonim',
      rating: double.tryParse(json['rate'].toString()) ?? 0.0,
      comment: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'service_id': serviceId,
      'user_id': userId,
      'user_name': userName,
      'rate': rating,
      'message': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ReviewModel {
  final String userName;
  final int rating;
  final String comment;

  ReviewModel({
    required this.userName,
    required this.rating,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userName: json['user_name'] ?? '',
      rating: int.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}

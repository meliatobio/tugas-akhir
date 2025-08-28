import 'package:flutter/material.dart';

List<Widget> buildStarRating(
  double rating, {
  double iconSize = 16,
  Color color = Colors.amber,
}) {
  List<Widget> stars = [];
  for (int i = 1; i <= 5; i++) {
    if (rating >= i) {
      stars.add(Icon(Icons.star, color: color, size: iconSize));
    } else if (rating >= i - 0.5) {
      stars.add(Icon(Icons.star_half, color: color, size: iconSize));
    } else {
      stars.add(Icon(Icons.star_border, color: color, size: iconSize));
    }
  }
  return stars;
}

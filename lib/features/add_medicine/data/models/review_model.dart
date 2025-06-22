import 'package:pharma_dashboard/features/add_medicine/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.name,
    required super.image,
    required super.rating,
    required super.date,
    required super.reviewDescription,
  });

  factory ReviewModel.fromEntity(ReviewEntity reviewEntity) {
    return ReviewModel(
      name: reviewEntity.name,
      image: reviewEntity.image,
      rating: reviewEntity.rating,
      date: reviewEntity.date,
      reviewDescription: reviewEntity.reviewDescription,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['name'] ?? 'Anonymous',
      image: json['image'] ?? '',
      rating: json['rating'] ?? 0.0,
      date: json['date'] ?? '',
      reviewDescription: json['reviewDescription'] ?? 'No review',
    );
  }

  toJson() {
    return {
      'name': name,
      'image': image,
      'rating': rating,
      'date': date,
      'reviewDescription': reviewDescription,
    };
  }
}

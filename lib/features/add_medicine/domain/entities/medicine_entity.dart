import 'dart:io';

import 'package:pharma_dashboard/features/add_medicine/domain/entities/review_entity.dart';

class MedicineEntity {
  late final String id;
  final String name;
  final String description;
  final String code;
  final int quantity;
  final bool isNewProduct;
  final File? image;
  final num price;
  String? subabaseORImageUrl;
  final String pharmacyName;
  final int pharmacyId;
  final String pharmcyAddress;
  final num avgRating;
  final int ratingCount;
  final List<ReviewEntity> reviews;
  final int discountRating;

  MedicineEntity({
    required this.id,
    required this.discountRating,
    required this.reviews,
    required this.pharmacyName,
    required this.pharmacyId,
    required this.pharmcyAddress,
    this.subabaseORImageUrl,
    required this.name,
    required this.description,
    required this.code,
    required this.quantity,
    required this.isNewProduct,
    this.image,
    required this.price,
    this.avgRating = 0,
    this.ratingCount = 0,
  });
}

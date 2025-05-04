import 'dart:io';

import 'package:pharma_dashboard/features/add_medicine/data/models/review_model.dart';

import '../../domain/entities/medicine_entity.dart';

class AddMedicineModel {
  final String name;
  final String description;
  final String code;
  final int quantity;
  final bool isNewProduct;
  final File image;
  final num price;
  String? subabaseORImageUrl;
  final String pharmacyName;
  final int pharmacyId;
  final String pharmcyAddress;
  final num avgRating = 0;
  final int ratingCount = 0;
  final int discountRating;

  final List<ReviewModel> reviews;

  AddMedicineModel({
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
    required this.image,
    required this.price,
  });

  factory AddMedicineModel.fromEntity(MedicineEntity addMedicineInputEntity) {
    return AddMedicineModel(
      reviews:
          addMedicineInputEntity.reviews
              .map((e) => ReviewModel.fromEntity(e))
              .toList(),
      name: addMedicineInputEntity.name,
      description: addMedicineInputEntity.description,
      code: addMedicineInputEntity.code,
      quantity: addMedicineInputEntity.quantity,
      isNewProduct: addMedicineInputEntity.isNewProduct,
      image: addMedicineInputEntity.image,
      price: addMedicineInputEntity.price,
      pharmacyName: addMedicineInputEntity.pharmacyName,
      pharmacyId: addMedicineInputEntity.pharmacyId,
      pharmcyAddress: addMedicineInputEntity.pharmcyAddress,
      subabaseORImageUrl: addMedicineInputEntity.subabaseORImageUrl,
      discountRating: addMedicineInputEntity.discountRating,
    );
  }

  toJson() {
    return {
      'name': name,
      'description': description,
      'code': code,
      'quantity': quantity,
      'isNewProduct': isNewProduct,
      'price': price,
      'subabaseImageUrl':
          subabaseORImageUrl, // Make sure field name is consistent
      'discountRating': discountRating,
      'pharmacyName': pharmacyName,
      'pharmacyId': pharmacyId,
      'pharmcyAddress': pharmcyAddress,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }
}

import 'dart:io';

import 'package:pharma_dashboard/features/add_product/data/models/review_model.dart';

import '../../domain/entities/add_medicine_input_entity.dart';

class AddMedicineInputModel {
  final String name;
  final String description;
  final String code;
  final int quantity;
  final bool isNewProduct;
  final File image;
  final num price;
  String? imageUrl;
  final String pharmacyName;
  final int pharmacyId;
  final String pharmcyAddress;
  final num avgRating = 0;
  final int ratingCount = 0;

  final List<ReviewModel> reviews;

  AddMedicineInputModel({
    required this.reviews,
    required this.pharmacyName,
    required this.pharmacyId,
    required this.pharmcyAddress,
    this.imageUrl,
    required this.name,
    required this.description,
    required this.code,
    required this.quantity,
    required this.isNewProduct,
    required this.image,
    required this.price,
  });

  factory AddMedicineInputModel.fromEntity(
    AddMedicineInputEntity addMedicineInputEntity,
  ) {
    return AddMedicineInputModel(
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
      'imageUrl': imageUrl,

      'pharmacyName': pharmacyName,
      'pharmacyId': pharmacyId,
      'pharmcyAddress': pharmcyAddress,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }
}

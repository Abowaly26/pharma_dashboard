import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_dashboard/features/add_medicine/data/models/review_model.dart';

import '../../domain/entities/medicine_entity.dart';

class AddMedicineModel extends MedicineEntity {
  AddMedicineModel({
    required super.id,
    required super.discountRating,
    required super.reviews,
    required super.pharmacyName,
    required super.pharmacyId,
    required super.pharmcyAddress,
    super.subabaseORImageUrl,
    required super.name,
    required super.description,
    required super.code,
    required super.quantity,
    required super.isNewProduct,
    super.image,
    required super.price,
    super.avgRating,
    super.ratingCount,
  });

  factory AddMedicineModel.fromEntity(MedicineEntity addMedicineInputEntity) {
    return AddMedicineModel(
      id: addMedicineInputEntity.id,
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
  factory AddMedicineModel.fromJson(Map<String, dynamic> json) {
    return AddMedicineModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      description: json['description'] ?? 'No Description',
      code: json['code'] ?? 'No Code',
      quantity: json['quantity'] ?? 0,
      isNewProduct: json['isNewProduct'] ?? false,
      price: json['price'] ?? 0.0,
      subabaseORImageUrl: json['subabaseImageUrl'],
      discountRating: json['discountRating'] ?? 0,
      pharmacyName: json['pharmacyName'] ?? 'No Pharmacy Name',
      pharmacyId: json['pharmacyId'] ?? 0,
      pharmcyAddress: json['pharmcyAddress'] ?? 'No Pharmacy Address',
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      avgRating: json['avgRating'] ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
  toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'code': code,
      'quantity': quantity,
      'isNewProduct': isNewProduct,
      'price': price,
      'subabaseImageUrl': subabaseORImageUrl,
      'discountRating': discountRating,
      'pharmacyName': pharmacyName,
      'pharmacyId': pharmacyId,
      'pharmcyAddress': pharmcyAddress,
      'reviews': reviews.map((e) => (e as ReviewModel).toJson()).toList(),
      'avgRating': avgRating,
      'ratingCount': ratingCount,
    };
  }
}

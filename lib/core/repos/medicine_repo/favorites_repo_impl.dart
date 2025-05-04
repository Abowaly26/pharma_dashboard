import 'package:cloud_firestore/cloud_firestore.dart';

import 'favorites_repo.dart';

class FavoritesRepoImpl implements FavoritesRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addToFavorites({
    required String userId,
    required Map<String, dynamic> medicineData,
  }) async {
    final docId = medicineData['code'];
    await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(docId)
        .set(medicineData);
  }

  @override
  Future<List<Map<String, dynamic>>> getFavorites({
    required String userId,
  }) async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> removeFromFavorites({
    required String userId,
    required String medicineId,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(medicineId)
        .delete();
  }

  @override
  Future<bool> isFavorite({
    required String userId,
    required String medicineId,
  }) async {
    final doc =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(medicineId)
            .get();
    return doc.exists;
  }
}

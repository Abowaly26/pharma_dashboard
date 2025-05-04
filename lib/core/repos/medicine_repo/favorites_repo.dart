abstract class FavoritesRepo {
  Future<void> addToFavorites({
    required String userId,
    required Map<String, dynamic> medicineData,
  });
  Future<List<Map<String, dynamic>>> getFavorites({required String userId});
  Future<void> removeFromFavorites({
    required String userId,
    required String medicineId,
  });
  Future<bool> isFavorite({required String userId, required String medicineId});
}

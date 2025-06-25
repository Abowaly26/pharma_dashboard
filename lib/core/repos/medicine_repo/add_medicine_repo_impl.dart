import 'package:dartz/dartz.dart';
import 'package:pharma_dashboard/core/Services/data_service.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';
import 'package:pharma_dashboard/features/add_medicine/domain/entities/medicine_entity.dart';

import '../../../features/add_medicine/data/models/add_medicine_model.dart';
import '../../errors/failures.dart';
import '../../utils/backend_endpoint.dart';
import 'package:flutter/foundation.dart';
import 'package:pharma_dashboard/core/Services/supabase_storage.dart';

class MedicineRepoImpl implements MedicineRepo {
  final DatabaseService databaseService;

  MedicineRepoImpl(this.databaseService);
  @override
  Future<Either<Failure, void>> addMedicine(
    MedicineEntity addMedicineInputEntity,
  ) async {
    try {
      // Add data to the database
      await databaseService.addData(
        path: BackendEndpoint.addMedicine,
        data: AddMedicineModel.fromEntity(addMedicineInputEntity).toJson(),
      );
      // Return a Right object indicating success

      return const Right(null);
    } catch (e) {
      // Return a Left object indicating failure
      return Left(ServerFailure('Failed to add product'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalMedicinesCount() async {
    try {
      final data = await databaseService.getData(
        path: BackendEndpoint.addMedicine,
      );
      return Right(data.length);
    } catch (e) {
      return Left(ServerFailure('Failed to get medicines count'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedicine({
    required String medicineId,
  }) async {
    try {
      // Get all medicines to find the one to delete
      final allResult = await getProducts();
      if (allResult.isLeft()) {
        return Left(ServerFailure('Failed to fetch medicine for deletion'));
      }
      final medicines = allResult.getOrElse(() => []);
      final medicine = medicines.firstWhere(
        (m) => m.id == medicineId,
        orElse: () => throw Exception('Medicine not found'),
      );
      // Delete image from Supabase if exists
      if (medicine.subabaseORImageUrl != null &&
          medicine.subabaseORImageUrl!.isNotEmpty) {
        final url = medicine.subabaseORImageUrl!;
        // Extract the path after the bucket domain
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        // Find the index of 'Medicines_images' and get the rest as the file path
        final bucketIndex = segments.indexOf('Medicines_images');
        if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
          final filePath = segments.sublist(bucketIndex + 1).join('/');
          await SupabaseStorageService().deleteFile(filePath);
        }
      }
      // Delete from database
      await databaseService.deleteData(
        path: BackendEndpoint.addMedicine,
        documentId: medicineId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete medicine'));
    }
  }

  @override
  Future<Either<Failure, List<MedicineEntity>>> getProducts() async {
    try {
      final data = await databaseService.getData(
        path: BackendEndpoint.addMedicine,
      );
      final medicines =
          (data as List).map((e) => AddMedicineModel.fromJson(e)).toList();
      return Right(medicines);
    } catch (e, s) {
      debugPrint('Failed to get medicines: $e');
      debugPrint(s.toString());
      return Left(ServerFailure('Failed to get medicines'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicine({
    required MedicineEntity medicineEntity,
  }) async {
    try {
      await databaseService.addData(
        path: BackendEndpoint.addMedicine,
        documentId: medicineEntity.id,
        data: AddMedicineModel.fromEntity(medicineEntity).toJson(),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update medicine'));
    }
  }

  @override
  Stream<Either<Failure, int>> getTotalMedicinesCountStream() {
    try {
      return databaseService
          .getDataStream(path: BackendEndpoint.addMedicine)
          .map((snapshot) {
            return Right((snapshot as List).length);
          });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to get medicines count')));
    }
  }

  @override
  Stream<Either<Failure, int>> getLowStockCount() {
    try {
      return databaseService
          .getDataStream(path: BackendEndpoint.addMedicine)
          .map((snapshot) {
            int lowStockCount = 0;
            for (var doc in (snapshot as List)) {
              final medicine = AddMedicineModel.fromJson(doc);
              if (medicine.quantity <= 10) {
                lowStockCount++;
              }
            }
            return Right(lowStockCount);
          });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to get low stock count')));
    }
  }

  @override
  Future<Either<Failure, List<MedicineEntity>>> getLowStockMedicines() async {
    try {
      final data = await databaseService.getData(
        path: BackendEndpoint.addMedicine,
      );
      final medicines =
          (data as List).map((e) => AddMedicineModel.fromJson(e)).toList();
      final lowStockMedicines =
          medicines.where((element) => element.quantity <= 10).toList();
      return Right(lowStockMedicines);
    } catch (e, s) {
      debugPrint('Failed to get medicines: $e');
      debugPrint(s.toString());
      return Left(ServerFailure('Failed to get medicines'));
    }
  }
}

import 'package:dartz/dartz.dart';

import '../../../features/add_medicine/domain/entities/medicine_entity.dart';
import '../../errors/failures.dart';

abstract class MedicineRepo {
  Future<Either<Failure, void>> addMedicine(
    MedicineEntity addMedicineInputEntity,
  );
  Future<Either<Failure, int>> getTotalMedicinesCount();
  Future<Either<Failure, List<MedicineEntity>>> getProducts();
  Future<Either<Failure, void>> deleteMedicine({required String medicineId});
  Future<Either<Failure, void>> updateMedicine({
    required MedicineEntity medicineEntity,
  });
}

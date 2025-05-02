import 'package:dartz/dartz.dart';
import 'package:pharma_dashboard/core/Services/data_service.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';
import 'package:pharma_dashboard/features/add_product/data/models/add_medicine_input_model.dart';
import 'package:pharma_dashboard/features/add_product/domain/entities/add_medicine_input_entity.dart';

import '../../errors/failures.dart';
import '../../utils/backend_endpoint.dart';

class MedicineRepoImpl implements MedicineRepo {
  final DatabaseService databaseService;

  MedicineRepoImpl(this.databaseService);
  @override
  Future<Either<Failure, void>> addMedicine(
    AddMedicineInputEntity addMedicineInputEntity,
  ) async {
    try {
      // Add data to the database
      await databaseService.addData(
        path: BackendEndpoint.addMedicine,
        data: AddMedicineInputModel.fromEntity(addMedicineInputEntity).toJson(),
      );
      // Return a Right object indicating success

      return const Right(null);
    } catch (e) {
      // Return a Left object indicating failure
      return Left(ServerFailure('Failed to add product'));
    }
  }
}

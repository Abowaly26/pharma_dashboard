import 'package:dartz/dartz.dart';
import 'package:pharma_dashboard/core/Services/data_service.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';
import 'package:pharma_dashboard/features/add_medicine/domain/entities/medicine_entity.dart';

import '../../../features/add_medicine/data/models/add_medicine_model.dart';
import '../../errors/failures.dart';
import '../../utils/backend_endpoint.dart';

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
}

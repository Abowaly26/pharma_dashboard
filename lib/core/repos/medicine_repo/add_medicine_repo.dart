import 'package:dartz/dartz.dart';

import '../../../features/add_product/domain/entities/add_medicine_input_entity.dart';
import '../../errors/failures.dart';

abstract class MedicineRepo {
  Future<Either<Failure, void>> addMedicine(
    AddMedicineInputEntity addMedicineInputEntity,
  );
}

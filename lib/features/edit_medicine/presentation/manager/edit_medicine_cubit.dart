import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';
import 'package:pharma_dashboard/features/add_medicine/domain/entities/medicine_entity.dart';

part 'edit_medicine_state.dart';

class EditMedicineCubit extends Cubit<EditMedicineState> {
  final MedicineRepo medicineRepo;

  EditMedicineCubit(this.medicineRepo) : super(EditMedicineInitial());

  Future<void> getMedicines() async {
    emit(EditMedicineLoading());
    final result = await medicineRepo.getProducts();
    result.fold(
      (failure) => emit(EditMedicineFailure(failure.message)),
      (medicines) => emit(EditMedicineSuccess(medicines)),
    );
  }

  Future<void> deleteMedicine(String medicineId) async {
    emit(EditMedicineDeleteLoading(medicineId));
    final result = await medicineRepo.deleteMedicine(medicineId: medicineId);
    result.fold(
      (failure) => emit(EditMedicineDeleteFailure(failure.message)),
      (success) => emit(EditMedicineDeleteSuccess()),
    );
    getMedicines(); // Refetch the list after deletion
  }
}

part of 'edit_medicine_cubit.dart';

@immutable
abstract class EditMedicineState {}

class EditMedicineInitial extends EditMedicineState {}

class EditMedicineLoading extends EditMedicineState {}

class EditMedicineSuccess extends EditMedicineState {
  final List<MedicineEntity> medicines;
  EditMedicineSuccess(this.medicines);
}

class EditMedicineFailure extends EditMedicineState {
  final String message;
  EditMedicineFailure(this.message);
}

class EditMedicineDeleteLoading extends EditMedicineState {
  final String medicineId;
  EditMedicineDeleteLoading(this.medicineId);
}

class EditMedicineDeleteSuccess extends EditMedicineState {}

class EditMedicineDeleteFailure extends EditMedicineState {
  final String message;
  EditMedicineDeleteFailure(this.message);
}

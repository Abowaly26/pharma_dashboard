part of 'add_medicine_cubit.dart';

@immutable
sealed class AddMedicineState {}

final class AddMedicineInitial extends AddMedicineState {}

final class AddMedicineLoading extends AddMedicineState {}

final class AddMedicineFailure extends AddMedicineState {
  final String errMessage;

  AddMedicineFailure(this.errMessage);
}

final class AddMedicineSuccess extends AddMedicineState {
  // final List<ProductEntity> products;

  // ProductsSuccess(this.products);
}

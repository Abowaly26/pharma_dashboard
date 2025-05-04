import 'package:bloc/bloc.dart';

import 'package:meta/meta.dart';
import 'package:pharma_dashboard/core/repos/images_repo/images_repo.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';

import '../../../domain/entities/medicine_entity.dart';

part 'add_medicine_state.dart';

class AddMedicineCubit extends Cubit<AddMedicineState> {
  AddMedicineCubit(this.medicineRepo, this.imagesRepo)
    : super(AddMedicineInitial());

  final MedicineRepo medicineRepo;
  final ImagesRepo imagesRepo;

  Future<void> addMedicine(MedicineEntity addMedicineInputEntity) async {
    emit(AddMedicineLoading());

    // If there's already a URL link, use it directly without uploading
    if (addMedicineInputEntity.subabaseORImageUrl != null &&
        addMedicineInputEntity.subabaseORImageUrl!.isNotEmpty) {
      // Use URL directly
      var result = await medicineRepo.addMedicine(addMedicineInputEntity);
      result.fold(
        (f) {
          emit(AddMedicineFailure(f.message));
        },
        (r) {
          emit(AddMedicineSuccess());
        },
      );
    } else {
      // If there's a local image file, upload it first
      var result = await imagesRepo.uploadImage(addMedicineInputEntity.image);
      result.fold(
        (f) {
          emit(AddMedicineFailure(f.message));
        },
        (url) async {
          addMedicineInputEntity.subabaseORImageUrl = url;
          var result = await medicineRepo.addMedicine(addMedicineInputEntity);
          result.fold(
            (f) {
              emit(AddMedicineFailure(f.message));
            },
            (r) {
              emit(AddMedicineSuccess());
            },
          );
        },
      );
    }
  }
}

  // final MedicineRepo productsRepo;

  // int productsLength = 0;
  // Future<void> getMedicine() async {
  //   emit(MedicineLoading());
  //   final result = await productsRepo.getProducts();
  //   result.fold(
  //     (failure) => emit(MedicineFailure(failure.message)),
  //     (products) => emit(MedicineSuccess(products)),
  //   );
  // }

  // Future<void> getBestSellingroducts() async {
  //   emit(MedicineLoading());
  //   final result = await productsRepo.getBestSellingProducts();
  //   result.fold((failure) => emit(MedicineFailure(failure.message)), (
  //     products,
  //   ) {
  //     productsLength = products.length;
  //     emit(MedicineSuccess(products));
  //   });
  // }


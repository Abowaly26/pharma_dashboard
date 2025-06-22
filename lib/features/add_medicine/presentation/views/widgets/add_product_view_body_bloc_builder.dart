import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_dashboard/core/helper_functions.dart/build_error_bar.dart';
import 'package:pharma_dashboard/core/widgets/custom_progress_hud.dart';
import 'package:pharma_dashboard/features/add_medicine/presentation/manager/products_cubit/add_medicine_cubit.dart';

import '../../../domain/entities/medicine_entity.dart';
import 'add_medicine_view_body.dart';

class AddMedicineViewBodyBlocBuilder extends StatelessWidget {
  const AddMedicineViewBodyBlocBuilder({super.key, this.medicine});
  final MedicineEntity? medicine;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddMedicineCubit, AddMedicineState>(
      listener: (context, state) {
        if (state is AddMedicineSuccess) {
          buildBar(context, 'Medicine added successfully');
          Navigator.pop(context);
        }
        if (state is AddMedicineFailure) {
          buildBar(context, state.errMessage);
        }
      },
      builder: (context, state) {
        return CustomProgressHud(
          isLoading: state is AddMedicineLoading,
          child: AddMedicineViewBody(medicine: medicine),
        ); // (child: const AddMedicineViewBody());
      },
    );
  }
}

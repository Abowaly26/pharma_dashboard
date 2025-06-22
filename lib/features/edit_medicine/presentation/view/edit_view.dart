import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_dashboard/core/services/get_it_service.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';
import 'package:pharma_dashboard/core/utils/color_manger.dart';
import 'package:pharma_dashboard/features/edit_medicine/presentation/manager/edit_medicine_cubit.dart';
import 'package:pharma_dashboard/features/edit_medicine/presentation/view/widgets/edit_view_body.dart';

class EditView extends StatelessWidget {
  const EditView({super.key});
  static const String routeName = 'edit_view';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => EditMedicineCubit(getIt<MedicineRepo>())..getMedicines(),
      child: Scaffold(
        backgroundColor: ColorManager.primaryColor,
        appBar: AppBar(
          title: const Text('Manage Inventory'),
          backgroundColor: const Color(0xFF667EEA),
        ),
        body: const EditViewBody(),
      ),
    );
  }
}

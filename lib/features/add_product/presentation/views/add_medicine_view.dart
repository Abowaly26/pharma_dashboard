import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/Services/get_it_service.dart';
import 'package:pharma_dashboard/features/add_product/presentation/manager/products_cubit/add_medicine_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/repos/images_repo/images_repo.dart';
import '../../../../core/repos/medicine_repo/add_medicine_repo.dart';
import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../dashboard/views/dashboard_view.dart';
import 'widgets/add_medicine_view_body.dart';
import 'widgets/add_product_view_body_bloc_builder.dart';

class AddMedicineView extends StatelessWidget {
  const AddMedicineView({super.key});
  static const String routeName = 'AddProductView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Add Medicine ',
          isBack: true,
          onPressed: () {
            Navigator.pushReplacementNamed(context, DashboardView.routeName);
          },
        ),
      ),
      body: BlocProvider(
        create:
            (context) => AddMedicineCubit(
              getIt.get<MedicineRepo>(),
              getIt.get<ImagesRepo>(),
            ),
        child: AddMedicineViewBodyBlocBuilder(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_dashboard/core/utils/app_images.dart';
import 'package:pharma_dashboard/core/utils/color_manger.dart';

import '../../../../core/utils/button_style.dart';
import '../../../add_medicine/presentation/views/add_medicine_view.dart';

class DashboardViewBody extends StatelessWidget {
  const DashboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Image.asset(width: 300.w, height: 300.h, Assets.profile),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyles.primaryButton,
            onPressed: () {
              Navigator.pushNamed(context, AddMedicineView.routeName);
            },
            child: Text(
              'Add Data',
              style: TextStyle(color: ColorManager.colorLines),
            ),
          ),
        ],
      ),
    );
  }
}

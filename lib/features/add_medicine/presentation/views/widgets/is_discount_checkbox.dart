import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/utils/color_manger.dart';
import 'package:pharma_dashboard/core/widgets/custom_check_box.dart';

class IsDiscountCheckBox extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  const IsDiscountCheckBox({
    Key? key,
    required this.onChanged,
    this.initialValue = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckBox(isChecked: initialValue, onChecked: onChanged),
        SizedBox(width: 8.w),
        Text(
          'Apply Discount',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: ColorManager.colorOfArrows,
          ),
        ),
      ],
    );
  }
}

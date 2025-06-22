import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/widgets/custom_check_box.dart';

import '../utils/color_manger.dart';
import '../utils/text_style.dart';

class IsNewMedicineCheckBox extends StatefulWidget {
  const IsNewMedicineCheckBox({
    super.key,
    required this.onChanged,
    this.initialValue = false,
  });

  final ValueChanged<bool> onChanged;
  final bool initialValue;
  @override
  State<IsNewMedicineCheckBox> createState() => _IsNewMedicineCheckBoxState();
}

class _IsNewMedicineCheckBoxState extends State<IsNewMedicineCheckBox> {
  late bool isTermsAccepted;
  @override
  void initState() {
    super.initState();
    isTermsAccepted = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckBox(
          onChecked: (value) {
            isTermsAccepted = value;
            widget.onChanged(value);
            setState(() {});
          },
          isChecked: isTermsAccepted,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Is this a new medicine?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorOfArrows,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

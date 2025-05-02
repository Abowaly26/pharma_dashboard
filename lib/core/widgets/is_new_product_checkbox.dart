import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pharma_dashboard/core/widgets/custom_check_box.dart';

import '../utils/text_style.dart';

class IsNewMedicineCheckBox extends StatefulWidget {
  const IsNewMedicineCheckBox({super.key, required this.onChanged});

  final ValueChanged<bool> onChanged;
  @override
  State<IsNewMedicineCheckBox> createState() => _IsNewMedicineCheckBoxState();
}

class _IsNewMedicineCheckBoxState extends State<IsNewMedicineCheckBox> {
  bool isTermsAccepted = false;
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
        const SizedBox(width: 16),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Is this a new medicine?',
                  style: TextStyles.semiBold13.copyWith(
                    color: const Color(0xFF4F5A69),
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

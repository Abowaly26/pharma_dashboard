import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/color_manger.dart';
import '../utils/text_style.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.lable,
    this.icon,
    this.hint,
    this.onSaved,
    required this.textInputType,
    this.validator,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    String? title,
    this.maxLines,
    this.inputFormatters,
  });

  final String? lable;
  final String? icon;
  final String? hint;
  final TextInputType textInputType;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    // Moved the logic inside the build method to avoid creating new objects on every rebuild
    final effectiveInputFormatters =
        inputFormatters ?? _getDefaultFormatters(textInputType);
    final effectiveValidator =
        validator ?? _getDefaultValidator(textInputType, validator);

    return Column(
      children: [
        lable == null
            ? const SizedBox()
            : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text(lable ?? '', style: TextStyles.inputLabel16)],
            ),
        SizedBox(height: 8.h),
        TextFormField(
          maxLines: maxLines,
          obscureText: obscureText,
          controller: controller,
          keyboardType: textInputType,
          onSaved: onSaved,
          inputFormatters: effectiveInputFormatters,
          validator: effectiveValidator,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ColorManager.textInputColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ColorManager.redColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ColorManager.redColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ColorManager.textInputColor),
            ),
            prefixIcon:
                icon == null
                    ? null
                    : Padding(
                      padding: EdgeInsets.all(12.r),
                      child: SvgPicture.asset(
                        icon ?? '',
                        width: 24,
                        height: 24,
                      ),
                    ),
            hintText: hint,
            hintStyle: TextStyle(color: ColorManager.textInputColor),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  // Helper method to get appropriate formatters based on input type
  List<TextInputFormatter>? _getDefaultFormatters(TextInputType textInputType) {
    if (textInputType == TextInputType.number) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  // Default validator based on field type
  String? Function(String?)? _getDefaultValidator(
    TextInputType textInputType,
    String? Function(String?)? customValidator,
  ) {
    if (customValidator != null) return customValidator;

    // If no custom validator is provided, create a basic one based on the input type
    if (textInputType == TextInputType.number) {
      return (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      };
    } else {
      return (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      };
    }
  }
}

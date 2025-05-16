import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/widgets/button_style.dart';
import 'package:pharma_dashboard/core/widgets/is_new_product_checkbox.dart';
import 'package:pharma_dashboard/features/add_medicine/domain/entities/medicine_entity.dart';
import 'package:pharma_dashboard/features/add_medicine/domain/entities/review_entity.dart';
import 'package:pharma_dashboard/features/add_medicine/presentation/views/widgets/enhanced_image_input_field.dart';
import 'package:pharma_dashboard/features/add_medicine/presentation/views/widgets/is_discount_checkbox.dart'; // Import the new checkbox
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../manager/products_cubit/add_medicine_cubit.dart';

class AddMedicineViewBody extends StatefulWidget {
  const AddMedicineViewBody({super.key});

  @override
  State<AddMedicineViewBody> createState() => _AddMedicineViewBodyState();
}

class _AddMedicineViewBodyState extends State<AddMedicineViewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  // Initialize with default values to avoid null issues
  String? name, code, description;
  num price = 0;
  int quantity = 0;
  bool isNewProduct = false;
  // Added a new state for discount checkbox
  bool hasDiscount = false;
  int discountRating = 0;

  // Updated variables to handle both local image and URL
  File? image;
  String? imageUrl;

  int pharmcyId = 0;
  String? pharmcyName, pharmcyAddress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            children: [
              CustomTextField(
                onSaved: (value) {
                  name = value;
                },
                hint: 'Medicine Name',
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    price = num.tryParse(value) ?? 0;
                  }
                },
                hint: 'Medicine Price',
                textInputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (num.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              CustomTextField(
                onSaved: (value) {
                  code = value!.toLowerCase();
                },
                hint: 'Medicine Code',
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    quantity = int.tryParse(value) ?? 0;
                  }
                },
                hint: 'Medicine Quantity',
                textInputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                onSaved: (value) {
                  description = value;
                },
                hint: 'Product Description',
                textInputType: TextInputType.text,
                maxLines: 5,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                onSaved: (value) {
                  pharmcyName = value;
                },
                hint: 'Pharmacy Name',
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    pharmcyId = int.tryParse(value) ?? 0;
                  }
                },
                hint: 'Pharmacy ID',
                textInputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pharmacy ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                onSaved: (value) {
                  pharmcyAddress = value;
                },
                hint: 'Pharmacy Address',
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 16.h),
              // Add discount checkbox here
              IsDiscountCheckBox(
                initialValue: hasDiscount,
                onChanged: (value) {
                  setState(() {
                    hasDiscount = value;
                    // Reset discount rating if checkbox is unchecked
                    if (!value) {
                      discountRating = 0;
                    }
                  });
                },
              ),

              // Show discount rate field only if hasDiscount is true
              if (hasDiscount) ...[
                SizedBox(height: 16.h),
                CustomTextField(
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      discountRating = int.tryParse(value) ?? 0;
                    }
                  },
                  hint: 'Discount Rate',
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (hasDiscount) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a discount rate';
                      }
                      if (num.tryParse(value) == null) {
                        return 'Please enter a valid discount rate';
                      }
                    }
                    return null;
                  },
                ),
              ],

              SizedBox(height: 16.h),
              IsNewMedicineCheckBox(
                onChanged: (value) {
                  isNewProduct = value;
                },
              ),
              SizedBox(height: 16.h),

              // Enhanced image field
              EnhancedImageField(
                onFileChanged: (file) {
                  setState(() {
                    image = file;
                    // When selecting an image file, clear the URL
                    if (file != null) {
                      imageUrl = null;
                    }
                  });
                },
                onUrlChanged: (url) {
                  setState(() {
                    imageUrl = url;
                    // When entering a URL, clear the image file
                    if (url != null) {
                      image = null;
                    }
                  });
                },
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                style: ButtonStyles.primaryButton,
                onPressed: _submitForm,
                child: Text(
                  'Add Medicine',
                  style: TextStyle(color: ColorManager.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // Check if either an image file or URL is provided
    if (image == null && (imageUrl == null || imageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image or enter an image URL'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Use discountRating only if hasDiscount is true, otherwise set to 0
      final actualDiscountRating = hasDiscount ? discountRating : 0;

      final MedicineEntity input = MedicineEntity(
        reviews: [
          ReviewEntity(
            name: 'John Doe',
            date: DateTime.now().toIso8601String(),
            rating: 4,
            reviewDescription: 'Good product',
            image:
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQet2xOmvH86IcD05zovfeZJo19fgbgfrgi8g&s',
          ),
        ],
        discountRating: actualDiscountRating,
        name: name!,
        description: description!,
        code: code!,
        quantity: quantity,
        isNewProduct: isNewProduct,
        // Use empty file if we only have URL
        image: image ?? File(''),
        // Add image URL if available
        subabaseORImageUrl: imageUrl,
        price: price,
        pharmacyName: pharmcyName ?? '',
        pharmacyAddress: pharmcyAddress ?? '',
        pharmacyId: pharmcyId,
        pharmcyAddress: pharmcyAddress ?? '',
      );

      context.read<AddMedicineCubit>().addMedicine(input);
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }
}

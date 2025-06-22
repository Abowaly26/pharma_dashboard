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
  const AddMedicineViewBody({super.key, this.medicine});
  final MedicineEntity? medicine;

  @override
  State<AddMedicineViewBody> createState() => _AddMedicineViewBodyState();
}

class _AddMedicineViewBodyState extends State<AddMedicineViewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _codeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pharmacyNameController;
  late final TextEditingController _pharmacyIdController;
  late final TextEditingController _pharmacyAddressController;
  late final TextEditingController _discountRatingController;

  bool isNewProduct = false;
  bool hasDiscount = false;
  File? image;
  String? imageUrl;

  int pharmcyId = 0;
  String? pharmcyName, pharmcyAddress;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name);
    _priceController = TextEditingController(
      text: widget.medicine?.price.toString(),
    );
    _codeController = TextEditingController(text: widget.medicine?.code);
    _quantityController = TextEditingController(
      text: widget.medicine?.quantity.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.medicine?.description,
    );
    _pharmacyNameController = TextEditingController(
      text: widget.medicine?.pharmacyName,
    );
    _pharmacyIdController = TextEditingController(
      text: widget.medicine?.pharmacyId.toString(),
    );
    _pharmacyAddressController = TextEditingController(
      text: widget.medicine?.pharmcyAddress,
    );
    _discountRatingController = TextEditingController(
      text: widget.medicine?.discountRating.toString(),
    );

    isNewProduct = widget.medicine?.isNewProduct ?? false;
    hasDiscount = (widget.medicine?.discountRating ?? 0) > 0;
    imageUrl = widget.medicine?.subabaseORImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _codeController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _pharmacyNameController.dispose();
    _pharmacyIdController.dispose();
    _pharmacyAddressController.dispose();
    _discountRatingController.dispose();
    super.dispose();
  }

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
                controller: _nameController,
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
                controller: _priceController,
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
                controller: _codeController,
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
                controller: _quantityController,
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
                controller: _descriptionController,
                hint: 'Product Description',
                textInputType: TextInputType.text,
                maxLines: 5,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _pharmacyNameController,
                hint: 'Pharmacy Name',
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _pharmacyIdController,
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
                controller: _pharmacyAddressController,
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
                      _discountRatingController.text = '0';
                    }
                  });
                },
              ),

              // Show discount rate field only if hasDiscount is true
              if (hasDiscount) ...[
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _discountRatingController,
                  hint: 'Discount Rate (1-100)',
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    // منع إدخال أرقام أكبر من 100
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;

                      final value = int.tryParse(newValue.text);
                      if (value == null || value > 100) {
                        return oldValue; // إرجاع القيمة القديمة إذا كانت أكبر من 100
                      }
                      return newValue;
                    }),
                  ],
                  validator: (value) {
                    if (hasDiscount) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a discount rate';
                      }

                      final discountValue = int.tryParse(value);
                      if (discountValue == null) {
                        return 'Please enter a valid discount rate';
                      }

                      // التحقق من أن القيمة بين 1 و 100
                      if (discountValue < 1 || discountValue > 100) {
                        return 'Discount rate must be between 1 and 100';
                      }
                    }
                    return null;
                  },
                ),
              ],

              SizedBox(height: 16.h),
              IsNewMedicineCheckBox(
                initialValue: isNewProduct,
                onChanged: (value) {
                  setState(() {
                    isNewProduct = value;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Enhanced image field
              EnhancedImageField(
                initialUrl: imageUrl,
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
                    if (url != null && url.isNotEmpty) {
                      image = null;
                    }
                  });
                },
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                style: ButtonStyles.primaryButton,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final medicineEntity = MedicineEntity(
                      id:
                          widget.medicine?.id ??
                          '', // Use existing id or generate new one for new product
                      name: _nameController.text,
                      description: _descriptionController.text,
                      code: _codeController.text,
                      quantity: int.parse(_quantityController.text),
                      isNewProduct: isNewProduct,
                      price: num.parse(_priceController.text),
                      pharmacyName: _pharmacyNameController.text,
                      pharmacyId: int.parse(_pharmacyIdController.text),
                      pharmcyAddress: _pharmacyAddressController.text,
                      discountRating:
                          int.tryParse(_discountRatingController.text) ?? 0,
                      image: image,
                      subabaseORImageUrl: imageUrl,
                      reviews: widget.medicine?.reviews ?? [],
                    );
                    if (widget.medicine == null) {
                      context.read<AddMedicineCubit>().addMedicine(
                        medicineEntity,
                      );
                    } else {
                      context.read<AddMedicineCubit>().updateMedicine(
                        medicineEntity,
                      );
                    }
                  } else {
                    setState(() {
                      _autoValidateMode = AutovalidateMode.always;
                    });
                  }
                },
                child: Text(
                  widget.medicine == null ? 'Add Medicine' : 'Update Medicine',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

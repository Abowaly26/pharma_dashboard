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
import 'package:pharma_dashboard/features/add_medicine/presentation/views/widgets/is_discount_checkbox.dart';
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
  bool isLoading = false;
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE3EDFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.12),
              ),
            ),
            padding: EdgeInsets.all(7.w),
            child: Icon(icon, size: 18.sp, color: ColorManager.primaryColor),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: ColorManager.textInputColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.035),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F8FB),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Text(
                widget.medicine == null
                    ? 'Add New Medicine'
                    : 'Update Medicine',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.textInputColor,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                widget.medicine == null
                    ? 'Please fill in all the required information to add a new medicine'
                    : 'Update the medicine information below',
                style: TextStyle(fontSize: 13.sp, color: Color(0xFF6B7280)),
              ),

              SizedBox(height: 13.h),

              // Medicine Information Section
              _buildSectionTitle('Medicine Information', Icons.medication),
              SizedBox(height: 4.h),
              _buildInfoCard(
                child: Column(
                  children: [
                    CustomTextField(
                      lable: 'Medicine Name',
                      controller: _nameController,
                      hint: 'e.g. Paracetamol',
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Medicine name is required';
                        }
                        if (value.length < 2) {
                          return 'Medicine name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            lable: 'Price (\$)',
                            controller: _priceController,
                            hint: 'e.g. 12.50',
                            textInputType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Price is required';
                              }
                              final price = num.tryParse(value);
                              if (price == null) {
                                return 'Enter a valid price';
                              }
                              if (price <= 0) {
                                return 'Price must be greater than 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomTextField(
                            lable: 'Quantity',
                            controller: _quantityController,
                            hint: 'e.g. 100',
                            textInputType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Quantity is required';
                              }
                              final quantity = int.tryParse(value);
                              if (quantity == null) {
                                return 'Enter a valid quantity';
                              }
                              if (quantity < 0) {
                                return 'Quantity cannot be negative';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      lable: 'Medicine Code',
                      controller: _codeController,
                      hint: 'e.g. MED001',
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Medicine code is required';
                        }
                        if (value.length < 3) {
                          return 'Medicine code must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      lable: 'Product Description',
                      controller: _descriptionController,
                      hint: 'Short description...',
                      textInputType: TextInputType.multiline,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Pharmacy Information Section
              _buildSectionTitle('Pharmacy Information', Icons.local_pharmacy),
              SizedBox(height: 4.h),
              _buildInfoCard(
                child: Column(
                  children: [
                    CustomTextField(
                      lable: 'Pharmacy Name',
                      controller: _pharmacyNameController,
                      hint: 'e.g. Al Shifa Pharmacy',
                      textInputType: TextInputType.text,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      lable: 'Pharmacy ID',
                      controller: _pharmacyIdController,
                      hint: 'e.g. 123',
                      textInputType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pharmacy ID is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid pharmacy ID';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      lable: 'Pharmacy Address',
                      controller: _pharmacyAddressController,
                      hint: 'e.g. 123 Main St, City',
                      textInputType: TextInputType.multiline,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Additional Options Section
              _buildSectionTitle('Additional Options', Icons.tune),
              SizedBox(height: 4.h),
              _buildInfoCard(
                child: Column(
                  children: [
                    // New Product Checkbox
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50]?.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IsNewMedicineCheckBox(
                            initialValue: isNewProduct,
                            onChanged: (value) {
                              setState(() {
                                isNewProduct = value;
                              });
                            },
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Mark this medicine as a new product to highlight it to customers',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Discount Section
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.green[50]?.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.green[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IsDiscountCheckBox(
                            initialValue: hasDiscount,
                            onChanged: (value) {
                              setState(() {
                                hasDiscount = value;
                                if (!value) {
                                  _discountRatingController.text = '0';
                                }
                              });
                            },
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Enable discount pricing for this medicine',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.green[700],
                            ),
                          ),

                          // Discount Rate Field (conditional)
                          if (hasDiscount) ...[
                            SizedBox(height: 14.h),
                            CustomTextField(
                              lable: 'Discount Rate (%)',
                              controller: _discountRatingController,
                              hint: 'e.g. 10',
                              textInputType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
                                  if (newValue.text.isEmpty) return newValue;
                                  final value = int.tryParse(newValue.text);
                                  if (value == null || value > 100) {
                                    return oldValue;
                                  }
                                  return newValue;
                                }),
                              ],
                              validator: (value) {
                                if (hasDiscount) {
                                  if (value == null || value.isEmpty) {
                                    return 'Discount rate is required when discount is enabled';
                                  }
                                  final discountValue = int.tryParse(value);
                                  if (discountValue == null) {
                                    return 'Enter a valid discount rate';
                                  }
                                  if (discountValue < 1 ||
                                      discountValue > 100) {
                                    return 'Discount rate must be between 1 and 100';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Image Upload Section
              _buildSectionTitle('Medicine Image', Icons.photo_camera),
              SizedBox(height: 4.h),
              _buildInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload a clear image of the medicine or provide an image URL',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    EnhancedImageField(
                      initialUrl: imageUrl,
                      onFileChanged: (file) {
                        setState(() {
                          image = file;
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
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ButtonStyles.primaryButton.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Color(0xFF3B82F6),
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    elevation: MaterialStateProperty.all(3),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });

                              _formKey.currentState!.save();
                              final medicineEntity = MedicineEntity(
                                id: widget.medicine?.id ?? '',
                                name: _nameController.text,
                                description: _descriptionController.text,
                                code: _codeController.text,
                                quantity: int.parse(_quantityController.text),
                                isNewProduct: isNewProduct,
                                price: num.parse(_priceController.text),
                                pharmacyName: _pharmacyNameController.text,
                                pharmacyId: int.parse(
                                  _pharmacyIdController.text,
                                ),
                                pharmcyAddress: _pharmacyAddressController.text,
                                discountRating:
                                    int.tryParse(
                                      _discountRatingController.text,
                                    ) ??
                                    0,
                                image: image,
                                subabaseORImageUrl: imageUrl,
                                reviews: widget.medicine?.reviews ?? [],
                              );

                              try {
                                if (widget.medicine == null) {
                                  context.read<AddMedicineCubit>().addMedicine(
                                    medicineEntity,
                                  );
                                } else {
                                  context
                                      .read<AddMedicineCubit>()
                                      .updateMedicine(medicineEntity);
                                }
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            } else {
                              setState(() {
                                _autoValidateMode = AutovalidateMode.always;
                              });
                            }
                          },
                  child:
                      isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Processing...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.medicine == null
                                    ? Icons.add
                                    : Icons.update,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                widget.medicine == null
                                    ? 'Add Medicine'
                                    : 'Update Medicine',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                ),
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

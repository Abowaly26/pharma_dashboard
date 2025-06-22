import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/utils/color_manger.dart';
import 'package:pharma_dashboard/core/utils/text_style.dart';
import 'package:pharma_dashboard/features/add_medicine/domain/entities/medicine_entity.dart';
import 'package:pharma_dashboard/features/add_medicine/presentation/views/add_medicine_view.dart';
import 'package:pharma_dashboard/features/edit_medicine/presentation/manager/edit_medicine_cubit.dart';

// Enum to represent the stock status, making the logic cleaner and more readable.
enum StockStatus { inStock, lowStock, outOfStock }

class EditViewItem extends StatefulWidget {
  const EditViewItem({super.key, required this.medicine, required this.index})
    : assert(index >= 0, 'Index must be non-negative');

  final MedicineEntity medicine;
  final int index;

  @override
  State<EditViewItem> createState() => _EditViewItemState();
}

class _EditViewItemState extends State<EditViewItem>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isExpanded = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _validateMedicineData();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _validateMedicineData() {
    if (widget.medicine.quantity <= 0) {
      setState(() => _error = 'Invalid quantity');
    } else if (widget.medicine.price <= 0) {
      setState(() => _error = 'Invalid price');
    } else if (widget.medicine.name.isEmpty) {
      setState(() => _error = 'Missing name');
    } else if (widget.medicine.description.isEmpty) {
      setState(() => _error = 'Missing description');
    } else if (widget.medicine.code.isEmpty) {
      setState(() => _error = 'Missing code');
    } else if (widget.medicine.pharmacyName.isEmpty) {
      setState(() => _error = 'Missing pharmacy');
    } else if (widget.medicine.pharmacyId <= 0) {
      setState(() => _error = 'Invalid pharmacy ID');
    }
  }

  // Getter to determine stock status from medicine quantity
  StockStatus get stockStatus {
    if (_error != null) return StockStatus.outOfStock;
    if (widget.medicine.quantity <= 0) {
      return StockStatus.outOfStock;
    }
    if (widget.medicine.quantity < 10) {
      return StockStatus.lowStock;
    }
    return StockStatus.inStock;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        _error != null
                            ? LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.05),
                                Colors.red.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : null,
                    color: _error == null ? Colors.white : null,
                  ),
                  child: Column(
                    children: [
                      _buildMainContent(),
                      if (_isExpanded) _buildExpandedContent(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      height: 140.h,
      child: Row(
        children: [_buildImageSection(), Expanded(child: _buildInfoSection())],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: 140.w,
      height: 140.h,
      decoration: BoxDecoration(
        gradient:
            _error != null
                ? LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.1),
                    Colors.red.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : LinearGradient(
                  colors:
                      widget.index.isEven
                          ? [
                            ColorManager.lightBlueColorF5C,
                            ColorManager.lightBlueColorF5C.withOpacity(0.7),
                          ]
                          : [
                            ColorManager.lightGreenColorF5C,
                            ColorManager.lightGreenColorF5C.withOpacity(0.7),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          bottomLeft: Radius.circular(16.r),
        ),
      ),
      child: Stack(
        children: [
          if (_error != null)
            _buildErrorImageWidget()
          else
            _buildMedicineImage(),
          Positioned(bottom: 12.h, right: 12.w, child: _buildStockIndicator()),
          if (_isExpanded)
            Positioned(top: 12.h, right: 12.w, child: _buildExpandIcon()),
        ],
      ),
    );
  }

  Widget _buildMedicineImage() {
    if (widget.medicine.subabaseORImageUrl?.isEmpty ?? true) {
      return _buildNoImageWidget();
    }

    return Padding(
      padding: EdgeInsets.all(12.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: widget.medicine.subabaseORImageUrl ?? '',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => _buildShimmerLoading(),
          errorWidget: (context, url, error) => _buildErrorWidget(error),
          memCacheWidth: 140.w.toInt(),
          memCacheHeight: 140.h.toInt(),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      height: 180.h,
      padding: EdgeInsets.only(left: 6.h, right: 6.h, top: 6.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 8.h),
          _buildDescription(),
          const Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _error ?? widget.medicine.name ?? 'Unknown Medicine',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.listView_product_name.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      _error != null ? Colors.red : ColorManager.textInputColor,
                  height: 1.2,
                ),
              ),
              if (_error == null && widget.medicine.code.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      widget.medicine.code,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: ColorManager.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_error == null) ...[SizedBox(width: 8.w), _buildActionButtons()],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_rounded,
          color: const Color(0xFF667EEA),
          onPressed: () => _handleEdit(),
          tooltip: 'Edit Medicine',
        ),
        SizedBox(width: 8.w),
        _buildActionButton(
          icon: Icons.delete_rounded,
          color: const Color(0xFFFF6B6B),
          onPressed: () => _showDeleteConfirmation(),
          tooltip: 'Delete Medicine',
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (_error != null) return const SizedBox.shrink();

    return Text(
      widget.medicine.description ?? 'Medicine product',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12.sp,
        color: ColorManager.greyColor,
        height: 1.4,
      ),
    );
  }

  Widget _buildFooter() {
    if (_error != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          _error!,
          style: TextStyle(
            color: Colors.red,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Row(
      children: [Expanded(child: _buildQuantityInfo()), _buildPriceInfo()],
    );
  }

  Widget _buildQuantityInfo() {
    return Row(
      children: [
        Icon(
          Icons.inventory_2_rounded,
          size: 12.sp,
          color: ColorManager.greyColor,
        ),
        SizedBox(width: 2.w),
        Text(
          'Qty:${widget.medicine.quantity}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: ColorManager.textInputColor,
          ),
        ),
        SizedBox(width: 8.w),
        _buildQuantityStatus(),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.medicine.discountRating > 0) ...[
          Text(
            '${widget.medicine.price.toStringAsFixed(0)} EGP',
            style: TextStyle(
              fontSize: 11.sp,
              decoration: TextDecoration.lineThrough,
              color: ColorManager.greyColor,
            ),
          ),
          SizedBox(height: 2.h),
        ],
        Text(
          widget.medicine.discountRating > 0
              ? '${(widget.medicine.price - widget.medicine.discountRating).toStringAsFixed(0)} EGP'
              : '${widget.medicine.price.toStringAsFixed(0)} EGP',
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF20B83A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: ColorManager.greyColor.withOpacity(0.3)),
          SizedBox(height: 12.h),
          _buildExpandedInfo(),
        ],
      ),
    );
  }

  Widget _buildExpandedInfo() {
    return Column(
      children: [
        _buildInfoRow('Pharmacy', widget.medicine.pharmacyName),
        SizedBox(height: 8.h),
        _buildInfoRow('Medicine Code', widget.medicine.code),
        SizedBox(height: 8.h),
        _buildInfoRow('Category', 'General'),
        if (widget.medicine.discountRating > 0) ...[
          SizedBox(height: 8.h),
          _buildInfoRow(
            'Discount',
            '${widget.medicine.discountRating.toStringAsFixed(0)} %',
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12.sp,
              color: ColorManager.greyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: ColorManager.textInputColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }

  Widget _buildNoImageWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_rounded,
              size: 32.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImageWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40.sp,
            color: Colors.red.withOpacity(0.7),
          ),
          SizedBox(height: 8.h),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return _buildNoImageWidget();
  }

  Widget _buildStockIndicator() {
    final Color indicatorColor;
    switch (stockStatus) {
      case StockStatus.outOfStock:
        indicatorColor = Colors.red;
        break;
      case StockStatus.lowStock:
        indicatorColor = Colors.orange;
        break;
      case StockStatus.inStock:
        indicatorColor = Colors.green;
        break;
    }

    return Container(
      width: 16.w,
      height: 16.h,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: indicatorColor.withOpacity(0.3),
            blurRadius: 4.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandIcon() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4.r),
        ],
      ),
      child: Icon(
        _isExpanded ? Icons.expand_less : Icons.expand_more,
        size: 18.sp,
        color: ColorManager.secondaryColor,
      ),
    );
  }

  Widget _buildQuantityStatus() {
    final String statusText;
    final Color statusColor;

    switch (stockStatus) {
      case StockStatus.outOfStock:
        statusText = 'Out';
        statusColor = Colors.red;
        break;
      case StockStatus.lowStock:
        statusText = 'Low';
        statusColor = Colors.orange;
        break;
      case StockStatus.inStock:
        statusText = 'Stock';
        statusColor = Colors.green;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 9.sp,
          color: statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
        ),
      ),
    );
  }

  void _handleEdit() {
    if (widget.medicine.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMedicineView(medicine: widget.medicine),
        ),
      );
    } else {
      _showErrorSnackBar('Cannot edit: Invalid medicine ID');
    }
  }

  void _showDeleteConfirmation() {
    if (widget.medicine.id == null) {
      _showErrorSnackBar('Cannot delete: Invalid medicine ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.red,
                        size: 30.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Delete Medicine',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.textInputColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Are you sure you want to delete "${widget.medicine.name ?? 'Unknown Medicine'}"?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ColorManager.greyColor,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_isLoading) ...[
                      SizedBox(height: 24.h),
                      CircularProgressIndicator(
                        color: ColorManager.primaryColor,
                      ),
                    ],
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: ColorManager.greyColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => _performDelete(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child:
                                _isLoading
                                    ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performDelete(BuildContext dialogContext) async {
    setState(() => _isLoading = true);
    try {
      Navigator.of(dialogContext).pop();
      await context.read<EditMedicineCubit>().deleteMedicine(
        widget.medicine.id!,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error deleting medicine: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: ColorManager.primaryColor,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }
}

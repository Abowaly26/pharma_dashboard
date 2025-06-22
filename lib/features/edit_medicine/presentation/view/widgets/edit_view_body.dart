import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/utils/text_style.dart';
import 'package:pharma_dashboard/features/edit_medicine/presentation/manager/edit_medicine_cubit.dart';
import 'package:pharma_dashboard/features/edit_medicine/presentation/view/widgets/edit_view_item.dart';
import 'package:pharma_dashboard/features/add_medicine/domain/entities/medicine_entity.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/color_manger.dart';

class EditViewBody extends StatefulWidget {
  const EditViewBody({super.key});

  @override
  State<EditViewBody> createState() => _EditViewBodyState();
}

class _EditViewBodyState extends State<EditViewBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isSearching = false;
  List<MedicineEntity> _filteredMedicines = [];

  final List<String> _filterOptions = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<MedicineEntity> _filterMedicines(List<MedicineEntity> medicines) {
    List<MedicineEntity> filtered = medicines;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((medicine) {
            return medicine.name.toLowerCase().contains(_searchQuery) ||
                medicine.code.toLowerCase().contains(_searchQuery) ||
                medicine.description.toLowerCase().contains(_searchQuery) ||
                medicine.pharmacyName.toLowerCase().contains(_searchQuery);
          }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'In Stock':
        filtered = filtered.where((m) => m.quantity > 10).toList();
        break;
      case 'Low Stock':
        filtered =
            filtered.where((m) => m.quantity > 0 && m.quantity <= 10).toList();
        break;
      case 'Out of Stock':
        filtered = filtered.where((m) => m.quantity <= 0).toList();
        break;
      default:
        // 'All' - no additional filtering
        break;
    }

    return filtered;
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditMedicineCubit, EditMedicineState>(
      listener: (context, state) {
        if (state is EditMedicineDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: ColorManager.primaryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  const Text('Medicine deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.r),
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is EditMedicineDeleteFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Failed to delete: ${state.message}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.all(16.r),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  context.read<EditMedicineCubit>().getMedicines();
                },
              ),
            ),
          );
        }
      },
      child: BlocBuilder<EditMedicineCubit, EditMedicineState>(
        builder: (context, state) {
          if (state is EditMedicineSuccess) {
            _filteredMedicines = _filterMedicines(state.medicines);
            return _buildSuccessState(context, state);
          } else if (state is EditMedicineFailure) {
            return _buildErrorState(context, state.message);
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, EditMedicineSuccess state) {
    if (_filteredMedicines.isEmpty &&
        (_isSearching || _selectedFilter != 'All')) {
      return _buildEmptyState(isSearchResult: true);
    }
    if (state.medicines.isEmpty) {
      return _buildEmptyState(isSearchResult: false);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<EditMedicineCubit>().getMedicines();
      },
      color: ColorManager.primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medicine Inventory',
                            style: TextStyles.listView_product_name.copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.textInputColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${state.medicines.length} items',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: ColorManager.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      _buildQuickStatsCard(state.medicines),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildSearchAndFilter(),
                  SizedBox(height: 12.h),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),

          // Medicine list
          if (_filteredMedicines.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: EditViewItem(
                        medicine: _filteredMedicines[index],
                        index: index,
                      ),
                    ),
                  );
                }, childCount: _filteredMedicines.length),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                _onFilterChanged(filter);
              }
            },
            backgroundColor: ColorManager.buttom_info,
            selectedColor: Color(0xffFF667EEA),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : ColorManager.textInputColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(
                color:
                    isSelected
                        ? ColorManager.primaryColor
                        : ColorManager.lightBlueColorF5C,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          );
        },
      ),
    );
  }

  Widget _buildQuickStatsCard(List<MedicineEntity> medicines) {
    int inStock = medicines.where((m) => m.quantity > 10).length;
    int lowStock =
        medicines.where((m) => m.quantity > 0 && m.quantity <= 10).length;
    int outOfStock = medicines.where((m) => m.quantity <= 0).length;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorManager.lightBlueColorF5C),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('In Stock', inStock, Colors.green),
              SizedBox(width: 12.w),
              _buildStatItem('Low', lowStock, Colors.orange),
              SizedBox(width: 12.w),
              _buildStatItem('Out', outOfStock, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: ColorManager.greyColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ColorManager.lightBlueColorF5C),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search medicines by name, code, etc...',
          hintStyle: TextStyle(color: ColorManager.greyColor, fontSize: 14.sp),
          prefixIcon: Icon(
            Icons.search,
            color: ColorManager.greyColor,
            size: 20.sp,
          ),
          suffixIcon:
              _isSearching
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: ColorManager.greyColor,
                      size: 20.sp,
                    ),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool isSearchResult}) {
    String title;
    String message;
    IconData icon;
    Color iconColor;

    if (isSearchResult) {
      if (_isSearching && _selectedFilter != 'All') {
        title = 'No Matching Results';
        message =
            'No medicines match your search "$_searchQuery" and filter "$_selectedFilter"';
        icon = Icons.search_off;
        iconColor = Colors.orange;
      } else if (_isSearching) {
        title = 'No Search Results';
        message = 'No medicines found for "$_searchQuery"';
        icon = Icons.search_off;
        iconColor = Colors.orange;
      } else {
        title = 'No Filtered Results';
        message = 'No medicines match the "$_selectedFilter" filter';
        icon = Icons.filter_alt_off;
        iconColor = Colors.blue;
      }
    } else {
      title = 'No Medicines Yet';
      message =
          'Your inventory is empty. Add your first medicine to get started.';
      icon = Icons.medical_services_outlined;
      iconColor = ColorManager.primaryColor;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60.sp, color: iconColor),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyles.listView_product_name.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.textInputColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorManager.greyColor,
                height: 1.4,
              ),
            ),
            if (isSearchResult) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'All';
                    _clearSearch();
                  });
                },
                icon: Icon(Icons.clear, size: 18.sp),
                label: Text(
                  'Clear All Filters',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
              ),
            ] else ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to add medicine view
                },
                icon: Icon(Icons.add, size: 18.sp),
                label: Text(
                  'Add First Medicine',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
            ),
            SizedBox(height: 24.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyles.listView_product_name.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.textInputColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorManager.greyColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<EditMedicineCubit>().getMedicines();
              },
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text(
                'Try Again',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.buttom_info,
                foregroundColor: ColorManager.buttom_info,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: ColorManager.textInputColor.withOpacity(0.5),
      highlightColor: ColorManager.textInputColor.withOpacity(0.5),
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 200.w,
                            height: 24.h,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 120.w,
                            height: 16.h,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Container(
                        width: 100.w,
                        height: 50.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    height: 48.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    height: 38.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildShimmerPlaceholder(),
                );
              }, childCount: 5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 140.w,
            height: 140.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(width: 80.w, height: 16.h, color: Colors.white),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100.w,
                        height: 14.h,
                        color: Colors.white,
                      ),
                      Container(width: 50.w, height: 24.h, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_dashboard/core/Services/get_it_service.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';
import 'package:pharma_dashboard/features/add_medicine/presentation/views/add_medicine_view.dart';

class DashboardViewBody extends StatefulWidget {
  const DashboardViewBody({super.key});

  @override
  State<DashboardViewBody> createState() => _DashboardViewBodyState();
}

class _DashboardViewBodyState extends State<DashboardViewBody> {
  int _totalMedicines = 0;
  int _lowStockCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('Starting to load data...');
    setState(() {
      _isLoading = true;
    });

    try {
      await _fetchTotalMedicines();
      print('All data loaded successfully');
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _fetchLowStockCount() async {
  //   final repo = getIt<MedicineRepo>();
  //   final result = await repo.getLowStockMedicines();

  //   if (mounted) {
  //     setState(() {
  //       result.fold(
  //         (failure) {
  //           _lowStockCount = 0;
  //         },
  //         (medicines) {
  //           _lowStockCount = medicines.length;
  //         },
  //       );
  //     });
  //   }
  // }

  Future<void> _fetchTotalMedicines() async {
    final repo = getIt<MedicineRepo>();
    final result = await repo.getTotalMedicinesCount();

    if (mounted) {
      setState(() {
        result.fold(
          (failure) {
            _totalMedicines = 0;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load medicines count')),
            );
          },
          (count) {
            _totalMedicines = count;
          },
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: SafeArea(
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
                              'Welcome Back',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Pharmacy Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Stats Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.medication,
                          title: 'Total Medicines',
                          value:
                              _isLoading ? '...' : _totalMedicines.toString(),
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Navigator.pushNamed(
                            //   context,
                            //   LowStockView.routeName,
                            // );
                          },
                          child: _buildStatCard(
                            icon: Icons.warning_amber_rounded,
                            title: 'Low Stock',
                            value: _lowStockCount.toString(),
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // Quick Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildActionButton(
                        context: context,
                        icon: Icons.add_box_outlined,
                        title: 'Add New Medicine',
                        subtitle: 'Add a new product to the inventory',
                        color: const Color(0xFF0EA5E9),
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AddMedicineView.routeName,
                            ).then((_) => _loadData()),
                      ),
                      SizedBox(height: 16.h),
                      _buildActionButton(
                        context: context,
                        icon: Icons.edit_note_outlined,
                        title: 'Edit Medicine',
                        subtitle: 'Update product information',
                        color: const Color(0xFF8B5CF6),
                        onTap: () {},
                        // () => Navigator.pushNamed(
                        //   context,
                        //   EditView.routeName,
                        // ),
                      ),
                      SizedBox(height: 16.h),
                      _buildActionButton(
                        context: context,
                        icon: Icons.analytics_outlined,
                        title: 'Reports & Analytics',
                        subtitle: 'View sales and inventory reports',
                        color: const Color(0xFF7C3AED),
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AddMedicineView.routeName,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16.sp),
          ],
        ),
      ),
    );
  }
}

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/Services/get_it_service.dart';
import 'package:pharma_dashboard/core/errors/failures.dart';
import 'package:pharma_dashboard/core/repos/medicine_repo/add_medicine_repo.dart';
import 'package:pharma_dashboard/features/add_medicine/presentation/views/add_medicine_view.dart';
import 'package:pharma_dashboard/features/edit_medicine/presentation/view/edit_view.dart';

class DashboardViewBody extends StatelessWidget {
  const DashboardViewBody({super.key});

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
                        child: StreamBuilder<dartz.Either<Failure, int>>(
                          stream:
                              getIt<MedicineRepo>()
                                  .getTotalMedicinesCountStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _buildStatCard(
                                icon: Icons.medication,
                                title: 'Total Medicines',
                                value: 'Error',
                                color: const Color(0xFF3B82F6),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildStatCard(
                                icon: Icons.medication,
                                title: 'Total Medicines',
                                value: '...',
                                color: const Color(0xFF3B82F6),
                              );
                            }
                            if (!snapshot.hasData) {
                              return _buildStatCard(
                                icon: Icons.medication,
                                title: 'Total Medicines',
                                value: '0',
                                color: const Color(0xFF3B82F6),
                              );
                            }
                            final count = snapshot.data!.fold(
                              (l) => 'Error',
                              (r) => r.toString(),
                            );

                            return _buildStatCard(
                              icon: Icons.medication,
                              title: 'Total Medicines',
                              value: count,
                              color: const Color(0xFF3B82F6),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: StreamBuilder<dartz.Either<Failure, int>>(
                          stream: getIt<MedicineRepo>().getLowStockCount(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _buildStatCard(
                                icon: Icons.warning_amber_rounded,
                                title: 'Low Stock',
                                value: 'Error',
                                color: const Color(0xFFF59E0B),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildStatCard(
                                icon: Icons.warning_amber_rounded,
                                title: 'Low Stock',
                                value: '...',
                                color: const Color(0xFFF59E0B),
                              );
                            }
                            if (!snapshot.hasData) {
                              return _buildStatCard(
                                icon: Icons.warning_amber_rounded,
                                title: 'Low Stock',
                                value: '0',
                                color: const Color(0xFFF59E0B),
                              );
                            }
                            final count = snapshot.data!.fold(
                              (l) => 'Error',
                              (r) => r.toString(),
                            );
                            return _buildStatCard(
                              icon: Icons.warning_amber_rounded,
                              title: 'Low Stock',
                              value: count,
                              color: const Color(0xFFF59E0B),
                            );
                          },
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
                            ),
                      ),
                      SizedBox(height: 16.h),
                      _buildActionButton(
                        context: context,
                        icon: Icons.edit_note_outlined,
                        title: 'Edit Medicine',
                        subtitle: 'Update product information',
                        color: const Color(0xFF8B5CF6),
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              EditView.routeName,
                            ),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
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
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18.sp),
          ],
        ),
      ),
    );
  }
}

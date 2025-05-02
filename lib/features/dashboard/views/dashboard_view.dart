import 'package:flutter/material.dart';

import '../../../core/utils/color_manger.dart';
import 'widgets/dashboard_view_body.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  static const routeName = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: DashboardViewBody(),
    );
  }
}

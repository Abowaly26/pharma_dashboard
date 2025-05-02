import 'package:flutter/material.dart';
import 'package:pharma_dashboard/features/add_product/presentation/views/add_medicine_view.dart';

import '../../features/dashboard/views/dashboard_view.dart';

Route<dynamic> onGenerateRoute(RouteSettings setting) {
  switch (setting.name) {
    case DashboardView.routeName:
      return MaterialPageRoute(builder: (context) => const DashboardView());
    case AddMedicineView.routeName:
      return MaterialPageRoute(builder: (context) => const AddMedicineView());
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}

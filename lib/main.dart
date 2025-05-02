import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_dashboard/core/Services/get_it_service.dart';
import 'package:pharma_dashboard/core/Services/supabase_storage.dart';
import 'package:pharma_dashboard/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/Services/custom_bloc_observer.dart';
import 'core/helper_functions.dart/on_generate_route.dart';
import 'features/dashboard/views/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseStorageService.initSupabase();
  await SupabaseStorageService.createBuckets('Medicines_images');

  Bloc.observer = CustomBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupGetit();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: onGenerateRoute,
            initialRoute: DashboardView.routeName,
          ),
    );
  }
}

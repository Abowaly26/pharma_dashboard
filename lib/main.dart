import 'package:flutter/material.dart';

import 'core/helper_functions.dart/on_generate_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(onGenerateRoute: onGenerateRoute);
  }
}

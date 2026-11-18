import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FreeVehicleApp());
}

class FreeVehicleApp extends StatelessWidget {
  const FreeVehicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Vehicle • 40/30/30 Gold OD & SIP Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}

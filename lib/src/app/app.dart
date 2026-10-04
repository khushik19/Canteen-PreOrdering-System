import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import 'routes/app_router.dart';

class CanteenCraveApp extends StatelessWidget {
  const CanteenCraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Canteen Crave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
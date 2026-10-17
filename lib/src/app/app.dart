import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/state/campus_controller.dart';
import '../core/theme/theme.dart';
import '../core/utils/scroll_behavior.dart';
import '../screens/auth/auth_controller.dart';
import 'routes/app_router.dart';

// ---------------------------------------------------------------------------
// CanteenCraveApp — The root widget of the application.
//
// Uses a StatefulWidget so that:
//   1. Controllers are initialized before the first frame.
//   2. GoRouter is created once with AuthController as its refreshListenable.
//   3. MultiProvider supplies both AuthController and CampusController.
//   4. AppScrollBehavior enables mouse drag on desktop & web carousels.
// ---------------------------------------------------------------------------

class CanteenCraveApp extends StatefulWidget {
  const CanteenCraveApp({super.key});

  @override
  State<CanteenCraveApp> createState() => _CanteenCraveAppState();
}

class _CanteenCraveAppState extends State<CanteenCraveApp> {
  late final AuthController _authController;
  late final CampusController _campusController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _campusController = CampusController();
    _router = AppRouter.createRouter(_authController);
  }

  @override
  void dispose() {
    _authController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authController),
        ChangeNotifierProvider.value(value: _campusController),
      ],
      child: MaterialApp.router(
        title: 'Canteen Crave',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scrollBehavior: const AppScrollBehavior(),
        routerConfig: _router,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/state/campus_controller.dart';
import '../core/theme/theme.dart';
import '../core/utils/scroll_behavior.dart';
import '../repositories/menu_repository.dart';
import '../screens/auth/auth_controller.dart';
import '../screens/home/home_controller.dart';
import '../screens/menu/menu_page_controller.dart';
import 'routes/app_router.dart';

// ---------------------------------------------------------------------------
// CanteenCraveApp — The root widget of the application.
//
// Uses a StatefulWidget so that:
//   1. Controllers are initialized before the first frame.
//   2. GoRouter is created once with AuthController as its refreshListenable.
//   3. MultiProvider supplies AuthController, CampusController, and
//      HomeController (via ChangeNotifierProxyProvider so it auto-reloads
//      when the campus changes).
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
  // We share one repository instance across the app.
  final _menuRepository = MenuRepository();

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
        // --- Auth -------------------------------------------------------
        ChangeNotifierProvider.value(value: _authController),

        // --- Campus selection -------------------------------------------
        ChangeNotifierProvider.value(value: _campusController),

        // --- Home data --------------------------------------------------
        // ChangeNotifierProxyProvider listens to CampusController.
        // Whenever the campus changes, it calls update(), which calls
        // HomeController.load(newCampusId) — the Home screen reloads
        // automatically without any manual trigger.
        ChangeNotifierProxyProvider<CampusController, HomeController>(
          create: (_) => HomeController(_menuRepository),
          update: (_, campus, home) {
            // home is the existing controller (never null after create).
            home!.load(campus.campusId);
            return home;
          },
        ),

        // --- Menu data --------------------------------------------------
        // ChangeNotifierProxyProvider updates MenuPageController with the
        // active campus ID, keeping the selected category intact.
        ChangeNotifierProxyProvider<CampusController, MenuPageController>(
          create: (_) => MenuPageController(_menuRepository),
          update: (_, campus, menu) {
            menu!.updateCampus(campus.campusId);
            return menu;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Canteen Crave',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Enables mouse-drag scrolling for carousels on web/desktop.
        scrollBehavior: const AppScrollBehavior(),
        routerConfig: _router,
      ),
    );
  }
}

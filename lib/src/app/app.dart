import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../screens/auth/auth_controller.dart';
import 'routes/app_router.dart';

// ---------------------------------------------------------------------------
// CanteenCraveApp - the root widget of the application.
//
// What it does:
//   1. Creates AuthController and provides it to the widget tree via provider.
//   2. Gives the AuthController to the router (for redirect logic).
//   3. Uses MaterialApp.router with GoRouter and our AppTheme.
//
// The AuthController starts listening to Firebase auth state immediately
// in its constructor, so persistent login is handled automatically.
// ---------------------------------------------------------------------------

class CanteenCraveApp extends StatelessWidget {
  const CanteenCraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the app with ChangeNotifierProvider so every screen can
    // access auth state via context.watch<AuthController>().
    return ChangeNotifierProvider(
      // Create the AuthController — it starts listening to Firebase
      // auth state changes in its constructor.
      create: (_) {
        final authController = AuthController();
        // Give the router access to the controller so it can do redirects.
        AppRouter.setAuthController(authController);
        return authController;
      },
      child: MaterialApp.router(
        // --- App identity -------------------------------------------------
        title: 'Canteen Crave',
        debugShowCheckedModeBanner: false,

        // --- Theme --------------------------------------------------------
        theme: AppTheme.lightTheme,

        // --- Routing (GoRouter) -------------------------------------------
        routerConfig: AppRouter.router,
      ),
    );
  }
}

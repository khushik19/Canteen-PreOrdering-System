import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import 'routes/app_router.dart';

// ---------------------------------------------------------------------------
// CanteenCraveApp — the root widget of the application.
//
// What it does:
//   1. Uses MaterialApp.router with our GoRouter instance.
//   2. Applies AppTheme.lightTheme so every screen gets our design tokens.
//
// When we add providers (CampusProvider, AuthController, etc.), wrap this
// with a MultiProvider. For now there are no providers, so we skip it
// (MultiProvider crashes with an empty list).
// ---------------------------------------------------------------------------

class CanteenCraveApp extends StatelessWidget {
  const CanteenCraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Wrap with MultiProvider once we have providers to add.
    // return MultiProvider(
    //   providers: [ ... ],
    //   child: MaterialApp.router( ... ),
    // );
    return MaterialApp.router(
      // --- App identity ---------------------------------------------------
      title: 'Canteen Crave',
      debugShowCheckedModeBanner: false,

      // --- Theme ----------------------------------------------------------
      theme: AppTheme.lightTheme,

      // --- Routing (GoRouter) ---------------------------------------------
      routerConfig: AppRouter.router,
    );
  }
}

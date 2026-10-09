import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../screens/auth/auth_controller.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/menu/menu_screen.dart';
import '../screens/favourites/favourites_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/team/team_screen.dart';
import 'routes/app_routes.dart';

// ---------------------------------------------------------------------------
// CanteenCraveApp - the root widget of the application.
//
// WHY StatefulWidget?
//   We need to create both the AuthController and the GoRouter in one place.
//   GoRouter.refreshListenable needs the REAL AuthController at creation time
//   (not null). A StatefulWidget lets us build both in initState() before the
//   first frame is drawn.
// ---------------------------------------------------------------------------

class CanteenCraveApp extends StatefulWidget {
  const CanteenCraveApp({super.key});

  @override
  State<CanteenCraveApp> createState() => _CanteenCraveAppState();
}

class _CanteenCraveAppState extends State<CanteenCraveApp> {
  // Auth controller - starts listening to Firebase in its constructor.
  late final AuthController _authController;

  // GoRouter - built once with the real controller.
  late final GoRouter _router;

  // Unauthenticated routes that an unauthenticated user is allowed to view.
  // Note: AppRoutes.splash is intentionally NOT in this list, because
  // once auth check is finished, the user should be redirected away from splash.
  static const _authPages = [
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.forgotPassword,
  ];

  @override
  void initState() {
    super.initState();

    // 1. Create the auth controller first.
    _authController = AuthController();

    // 2. Build the router with the real controller as refreshListenable.
    //    Now whenever auth state changes, the router re-checks its redirect.
    _router = GoRouter(
      initialLocation: AppRoutes.splash,

      // Every time AuthController calls notifyListeners(), the router
      // re-runs this redirect function.
      refreshListenable: _authController,

      redirect: (context, state) {
        final status = _authController.status;
        final currentPath = state.matchedLocation;
        final isOnAuthPage = _authPages.contains(currentPath);

        // Still checking Firebase - show splash.
        if (status == AuthStatus.unknown) {
          return currentPath == AppRoutes.splash ? null : AppRoutes.splash;
        }

        // Not logged in:
        // If on login, signup, or forgot-password, let them stay.
        // Otherwise (including when on splash or any protected route), go to login.
        if (status == AuthStatus.unauthenticated) {
          return isOnAuthPage ? null : AppRoutes.login;
        }

        // Logged in and on splash or an auth page - redirect by role.
        if (status == AuthStatus.authenticated &&
            (isOnAuthPage || currentPath == AppRoutes.splash)) {
          final isVendor = _authController.currentUser?.isVendor ?? false;
          return isVendor ? AppRoutes.vendorDashboard : AppRoutes.home;
        }

        // Student navigating to vendor route - send back to home.
        if (status == AuthStatus.authenticated &&
            currentPath == AppRoutes.vendorDashboard) {
          final isVendor = _authController.currentUser?.isVendor ?? false;
          if (!isVendor) return AppRoutes.home;
        }

        return null; // no redirect needed
      },

      routes: [
        // --- Auth routes --------------------------------------------------
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          name: 'signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // --- Student screens ----------------------------------------------
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.menu,
          name: 'menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: AppRoutes.favourites,
          name: 'favourites',
          builder: (context, state) => const FavouritesScreen(),
        ),
        GoRoute(
          path: AppRoutes.cart,
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.team,
          name: 'team',
          builder: (context, state) => const TeamScreen(),
        ),

        // --- Vendor placeholder (Person C will replace this) --------------
        GoRoute(
          path: AppRoutes.vendorDashboard,
          name: 'vendorDashboard',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Vendor Dashboard - coming soon (Person C)'),
            ),
          ),
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            '404 - Page not found\n${state.uri}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the AuthController to the whole widget tree.
    return ChangeNotifierProvider.value(
      value: _authController,
      child: MaterialApp.router(
        title: 'Canteen Crave',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

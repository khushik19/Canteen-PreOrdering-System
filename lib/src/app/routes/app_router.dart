import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../../screens/auth/auth_controller.dart';
import '../../screens/auth/sign_in_screen.dart';
import '../../screens/auth/sign_up_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/menu/menu_screen.dart';
import '../../screens/favourites/favourites_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/team/team_screen.dart';

// ---------------------------------------------------------------------------
// AppRouter - GoRouter configuration with auth-aware redirect logic.
//
// How it works:
//   1. The router starts on /splash (shows logo + spinner).
//   2. refreshListenable points to the AuthController, so every time
//      auth state changes, the redirect function is re-evaluated.
//   3. The redirect function checks AuthController.status and
//      AuthController.currentUser?.role to decide where to send the user.
//
// Redirect rules (from AUTH_CONTEXT Section 9):
//   - status == unknown           -> /splash
//   - unauthenticated & not on auth page -> /login
//   - authenticated & on auth page -> role-based (/vendor or /home)
//   - route requires vendor & user is not vendor -> /home
//   - otherwise -> no redirect
// ---------------------------------------------------------------------------

class AppRouter {
  AppRouter._();

  /// The AuthController instance. Set by app.dart before the router is used.
  /// This lets the router listen for auth changes without importing provider.
  static AuthController? _authController;

  /// Call this once from app.dart to give the router access to auth state.
  static void setAuthController(AuthController controller) {
    _authController = controller;
  }

  // Routes that don't require authentication.
  static const _authPages = [
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.forgotPassword,
    AppRoutes.splash,
  ];

  static final GoRouter router = GoRouter(
    // Start on splash - auth state is unknown on app launch.
    initialLocation: AppRoutes.splash,

    // Re-evaluate redirect whenever auth state changes.
    refreshListenable: _authController,

    // --- Redirect logic ---------------------------------------------------
    redirect: (context, state) {
      final auth = _authController;
      if (auth == null) return AppRoutes.splash;

      final status = auth.status;
      final currentPath = state.matchedLocation;
      final isOnAuthPage = _authPages.contains(currentPath);

      // 1. Still loading (app just started) -> show splash.
      if (status == AuthStatus.unknown) {
        return currentPath == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // 2. Not logged in -> force to login (unless already on auth page).
      if (status == AuthStatus.unauthenticated) {
        return isOnAuthPage ? null : AppRoutes.login;
      }

      // 3. Logged in and on an auth page -> redirect by role.
      if (status == AuthStatus.authenticated && isOnAuthPage) {
        final isVendor = auth.currentUser?.isVendor ?? false;
        return isVendor ? AppRoutes.vendorDashboard : AppRoutes.home;
      }

      // 4. Student trying to access vendor route -> redirect to home.
      if (status == AuthStatus.authenticated &&
          currentPath == AppRoutes.vendorDashboard) {
        final isVendor = auth.currentUser?.isVendor ?? false;
        if (!isVendor) return AppRoutes.home;
      }

      // 5. All good -> no redirect.
      return null;
    },

    // --- Routes -----------------------------------------------------------
    routes: [
      // Auth routes
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

      // Student main screens
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

      // Other student screens
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

      // Vendor placeholder (Person C will replace this)
      GoRoute(
        path: AppRoutes.vendorDashboard,
        name: 'vendorDashboard',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Vendor Dashboard (Person C will build this)'),
          ),
        ),
      ),
    ],

    // 404 page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          '404 - Page not found\n${state.uri}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
}

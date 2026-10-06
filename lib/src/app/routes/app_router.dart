import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/menu/menu_screen.dart';
import '../../screens/favourites/favourites_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/team/team_screen.dart';
import '../../screens/vendor_auth/vendor_login_screen.dart';
import '../../screens/vendor_auth/vendor_register_screen.dart';
import '../../screens/vendor_dashboard/vendor_main_nav_screen.dart';

// ---------------------------------------------------------------------------
// AppRouter — GoRouter configuration for the whole app.
// ---------------------------------------------------------------------------

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,

    routes: [
      // --- Auth -----------------------------------------------------------
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // --- Student main screens ------------------------------------------
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

      // --- Other student screens -----------------------------------------
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

      // --- Vendor screens (Person C) -------------------------------------
      GoRoute(
        path: AppRoutes.vendorDashboard,
        name: 'vendorDashboard',
        builder: (context, state) => const VendorMainNavScreen(vendorId: 'vendor_demo_101'),
      ),
      GoRoute(
        path: AppRoutes.vendorLogin,
        name: 'vendorLogin',
        builder: (context, state) => const VendorLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorRegister,
        name: 'vendorRegister',
        builder: (context, state) => const VendorRegisterScreen(),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          '404 — Page not found\n${state.uri}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
}

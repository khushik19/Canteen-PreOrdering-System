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

// ---------------------------------------------------------------------------
// AppRouter — GoRouter configuration for the whole app.
//
// • Auth redirect is a TODO stub for now (we will wire it up in the auth
//   task once AuthService exists).
// • The bottom-nav shell will be added in the home task.
// • For now every route is a simple full-screen page.
// ---------------------------------------------------------------------------

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    // Start on the login screen until auth redirect is wired up.
    initialLocation: AppRoutes.login,

    // TODO: Add auth redirect once AuthService is built.
    // redirect: (context, state) { ... },

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
    ],

    // Nice error page instead of a crash when a route is not found.
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

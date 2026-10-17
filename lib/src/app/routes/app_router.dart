import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shell/app_shell.dart';
import 'app_routes.dart';
import '../../screens/auth/auth_controller.dart';
import '../../screens/auth/sign_in_screen.dart';
import '../../screens/auth/sign_up_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/menu/menu_screen.dart';
import '../../screens/placeholder/placeholder_screen.dart';

// ---------------------------------------------------------------------------
// AppRouter — GoRouter configuration with auth redirects and responsive shell.
//
// Features:
//   1. StatefulShellRoute with 4 branches: Home, Menu, Favs, Cart.
//      (Preserves scroll position when switching tabs).
//   2. Standalone routes outside shell: Auth, Profile, Team, Vendor.
//   3. Auth-aware redirection: listens to AuthController.
// ---------------------------------------------------------------------------

class AppRouter {
  AppRouter._();

  // Routes that don't require authentication.
  static const _authPages = [
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.forgotPassword,
  ];

  // Routes accessible by guest users without being bounced to login.
  static const _guestAllowedPaths = [
    AppRoutes.home,
    AppRoutes.menu,
    AppRoutes.favourites,
    AppRoutes.cart,
    AppRoutes.team,
    AppRoutes.profile,
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.forgotPassword,
  ];

  /// Builds a [GoRouter] wired with the provided [AuthController].
  static GoRouter createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authController,

      // --- Redirect logic -------------------------------------------------
      redirect: (context, state) {
        final status = authController.status;
        final currentPath = state.matchedLocation;
        final isOnAuthPage = _authPages.contains(currentPath);

        // 1. Still checking Firebase session -> show splash.
        if (status == AuthStatus.unknown) {
          return currentPath == AppRoutes.splash ? null : AppRoutes.splash;
        }

        // 2. Unauthenticated -> force login (unless already on auth page).
        if (status == AuthStatus.unauthenticated) {
          return isOnAuthPage ? null : AppRoutes.login;
        }

        // 3. Authenticated & currently on splash or an auth page -> redirect by role.
        if (status == AuthStatus.authenticated &&
            (isOnAuthPage || currentPath == AppRoutes.splash)) {
          final isVendor = authController.currentUser?.isVendor ?? false;
          return isVendor ? AppRoutes.vendorDashboard : AppRoutes.home;
        }

        // 4. Student attempting to access vendor routes -> send to home.
        if (status == AuthStatus.authenticated &&
            currentPath == AppRoutes.vendorDashboard) {
          final isVendor = authController.currentUser?.isVendor ?? false;
          if (!isVendor) return AppRoutes.home;
        }

        // 5. Guest mode:
        if (status == AuthStatus.guest) {
          if (currentPath == AppRoutes.splash ||
              currentPath == AppRoutes.vendorDashboard) {
            return AppRoutes.home;
          }
          if (_guestAllowedPaths.contains(currentPath)) {
            return null;
          }
          return AppRoutes.home;
        }

        return null;
      },

      // --- Route definitions ----------------------------------------------
      routes: [
        // Auth screens (No shell/navigation frame)
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

        // Standalone student screens (Outside bottom/side nav frame)
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const PlaceholderScreen(
            title: 'Profile',
            owner: 'Person D (Profile & Settings)',
            icon: Icons.account_circle_outlined,
          ),
        ),
        GoRoute(
          path: AppRoutes.team,
          name: 'team',
          builder: (context, state) => const PlaceholderScreen(
            title: 'Meet the Team',
            owner: 'Person D (About & Team)',
            icon: Icons.group_outlined,
          ),
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

        // -------------------------------------------------------------------
        // Responsive 4-tab shell: Home, Menu, Favs, Cart
        // -------------------------------------------------------------------
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: 'home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            // Branch 1: Menu
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.menu,
                  name: 'menu',
                  builder: (context, state) {
                    final categoryId = state.uri.queryParameters['category'];
                    return MenuScreen(initialCategoryId: categoryId);
                  },
                ),
              ],
            ),
            // Branch 2: Favourites (Person B)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.favourites,
                  name: 'favourites',
                  builder: (context, state) => const PlaceholderScreen(
                    title: 'Favourites',
                    owner: 'Person B (Favourites & Cart)',
                    icon: Icons.favorite_border_rounded,
                  ),
                ),
              ],
            ),
            // Branch 3: Cart (Person B)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.cart,
                  name: 'cart',
                  builder: (context, state) => const PlaceholderScreen(
                    title: 'Cart & Checkout',
                    owner: 'Person B (Cart & Payment)',
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],

      // 404 fallback
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
}

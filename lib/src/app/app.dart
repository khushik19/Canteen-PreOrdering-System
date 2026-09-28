import 'package:flutter/material.dart';
import '../screens/vendor_auth/vendor_login_screen.dart';

class CanteenCraveApp extends StatelessWidget {
  const CanteenCraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen Crave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121418),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFFFFB300),
          surface: Color(0xFF1E222A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E222A),
          elevation: 0,
        ),
      ),
      home: const VendorLoginScreen(),
    );
  }
}

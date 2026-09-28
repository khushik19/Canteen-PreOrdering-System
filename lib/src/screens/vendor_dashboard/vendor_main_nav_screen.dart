import 'package:flutter/material.dart';
import '../vendor_dashboard/vendor_dashboard_screen.dart';
import '../vendor_menu/vendor_menu_screen.dart';
import '../vendor_stock/vendor_stock_screen.dart';
import '../vendor_flash_sale/vendor_flash_sale_screen.dart';
import '../vendor_reports/vendor_reports_screen.dart';

class VendorMainNavScreen extends StatefulWidget {
  final String vendorId;
  final String campusId;

  const VendorMainNavScreen({
    super.key,
    required this.vendorId,
    this.campusId = 'Main Campus',
  });

  @override
  State<VendorMainNavScreen> createState() => _VendorMainNavScreenState();
}

class _VendorMainNavScreenState extends State<VendorMainNavScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      VendorDashboardScreen(vendorId: widget.vendorId),
      VendorMenuScreen(vendorId: widget.vendorId, campusId: widget.campusId),
      VendorStockScreen(vendorId: widget.vendorId),
      VendorFlashSaleScreen(vendorId: widget.vendorId, campusId: widget.campusId),
      VendorReportsScreen(vendorId: widget.vendorId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E222A),
          indicatorColor: const Color(0xFFFF6B00).withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFFFF6B00));
            }
            return const IconThemeData(color: Colors.white60);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Stock',
            ),
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined),
              selectedIcon: Icon(Icons.bolt),
              label: 'Flash Sale',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}

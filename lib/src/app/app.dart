import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../repositories/flash_sale_repository.dart';
import '../services/notification_service.dart';

// ---------------------------------------------------------------------------
// TEMPORARY test helpers — delete once each checkpoint is confirmed working.
// ---------------------------------------------------------------------------

Future<void> testFlashSaleWiring() async {
  final repo = FlashSaleRepository();
  debugPrint('Creating test flash sale...');
  final id = await repo.createFlashSale(
    orderId: 'test-order-1',
    itemId: 'test-item-1',
    itemName: 'Test Maggi',
    originalPrice: 60,
    discountPercent: 30,
    campusId: 'pimr-ug',
    validFor: const Duration(minutes: 30),
  );
  debugPrint('Created flash sale: $id');
  final sales = await repo.getActiveFlashSales('pimr-ug');
  debugPrint('Active sales: ${sales.length}');
  for (final sale in sales) {
    debugPrint(
      ' - ${sale.itemName}: '
      'Rs.${sale.originalPrice} -> Rs.${sale.discountedPrice.toStringAsFixed(0)} '
      '(${sale.discountPercent}% off)',
    );
  }
}

Future<void> testNotificationWiring(String testUserId) async {
  // flutter_local_notifications does not support web —
  // skip local notification setup on web, FCM token registration still works.
  final service = NotificationService();
  await service.initialize(userId: testUserId);
  debugPrint('Notification service initialized for $testUserId');
}

// ---------------------------------------------------------------------------
// App root
// ---------------------------------------------------------------------------

class CanteenCraveApp extends StatelessWidget {
  const CanteenCraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen Crave',
      debugShowCheckedModeBanner: false,
      home: const _TestHomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Temporary test screen
// ---------------------------------------------------------------------------

class _TestHomeScreen extends StatefulWidget {
  const _TestHomeScreen();

  @override
  State<_TestHomeScreen> createState() => _TestHomeScreenState();
}

class _TestHomeScreenState extends State<_TestHomeScreen> {
  bool _flashSaleLoading = false;
  bool _notifLoading = false;
  String _flashSaleStatus = 'Tap to test Firestore flash sale wiring.';
  String _notifStatus = kIsWeb
      ? 'On web: FCM token registration only (local notifications require Android).'
      : 'Tap to test notification service wiring.';

  Future<void> _runFlashSaleTest() async {
    setState(() {
      _flashSaleLoading = true;
      _flashSaleStatus = 'Running...';
    });
    try {
      await testFlashSaleWiring();
      setState(() {
        _flashSaleStatus =
            'Success! Check debug console + Firebase Console '
            '-> Firestore -> flash_sales.';
      });
    } catch (e) {
      setState(() => _flashSaleStatus = 'Error: $e');
      debugPrint('testFlashSaleWiring failed: $e');
    } finally {
      setState(() => _flashSaleLoading = false);
    }
  }

  Future<void> _runNotificationTest() async {
    setState(() {
      _notifLoading = true;
      _notifStatus = 'Running...';
    });
    try {
      await testNotificationWiring('test-user-001');
      setState(() {
        _notifStatus = kIsWeb
            ? 'FCM token registered (web). Check Firestore -> users/test-user-001.'
            : 'Success! FCM token registered. Check debug console + '
              'Firestore -> users/test-user-001/fcmTokens.';
      });
    } catch (e) {
      setState(() => _notifStatus = 'Error: $e');
      debugPrint('testNotificationWiring failed: $e');
    } finally {
      setState(() => _notifLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canteen Crave - Dev Test Screen')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _TestCard(
            title: 'Phase 2 - Flash Sale Firestore',
            status: _flashSaleStatus,
            isLoading: _flashSaleLoading,
            onTest: _runFlashSaleTest,
            buttonLabel: 'Test Flash Sale Wiring',
          ),
          const SizedBox(height: 24),
          _TestCard(
            title: 'Phase 3 - Notification Service',
            status: _notifStatus,
            isLoading: _notifLoading,
            onTest: _runNotificationTest,
            buttonLabel: 'Test Notification Wiring',
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final String title;
  final String status;
  final bool isLoading;
  final VoidCallback onTest;
  final String buttonLabel;

  const _TestCard({
    required this.title,
    required this.status,
    required this.isLoading,
    required this.onTest,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : onTest,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(buttonLabel),
            ),
            const SizedBox(height: 12),
            Text(
              status,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/vendor_model.dart';
import '../../repositories/vendor_repository.dart';
import 'widgets/live_order_card.dart';

class VendorDashboardScreen extends StatefulWidget {
  final String vendorId;

  const VendorDashboardScreen({super.key, required this.vendorId});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _vendorRepository = VendorRepository();
  VendorModel? _vendorProfile;
  bool _isStoreOpen = true;
  bool _isSimulating = false;

  late TabController _tabController;
  final List<String> _tabLabels = ['All Active', 'New (Placed)', 'In Kitchen', 'Ready for Pickup', 'History'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _loadVendorProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVendorProfile() async {
    try {
      final profile = await _vendorRepository.getVendorProfile(widget.vendorId);
      if (mounted) {
        setState(() {
          _vendorProfile = profile ??
              VendorModel(
                id: widget.vendorId,
                canteenName: 'Main Campus Canteen',
                campusId: 'Main Campus',
                ownerName: 'Canteen Staff',
                email: 'canteen@campus.edu',
                phone: '9876543210',
                isOpen: true,
                createdAt: DateTime.now(),
              );
          _isStoreOpen = _vendorProfile!.isOpen;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleStoreStatus(bool val) async {
    setState(() => _isStoreOpen = val);
    try {
      await _vendorRepository.toggleStoreStatus(widget.vendorId, val);
    } catch (_) {}
  }

  Future<void> _simulateIncomingOrder() async {
    setState(() => _isSimulating = true);
    try {
      await _vendorRepository.simulateStudentOrder(
        vendorId: widget.vendorId,
        campusId: _vendorProfile?.campusId ?? 'Main Campus',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 New Student Order Placed! (Live Streamed to Dashboard)'),
            backgroundColor: Color(0xFF3B82F6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, int tabIndex) {
    switch (tabIndex) {
      case 0: // All active
        return orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).toList();
      case 1: // Placed / New
        return orders.where((o) => o.status == OrderStatus.placed).toList();
      case 2: // Kitchen
        return orders.where((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.preparing).toList();
      case 3: // Ready
        return orders.where((o) => o.status == OrderStatus.ready).toList();
      case 4: // History
        return orders.where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.uncollected || o.status == OrderStatus.cancelled).toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: _vendorRepository.streamActiveOrders(widget.vendorId),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];

        final activeCount = orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).length;
        final placedCount = orders.where((o) => o.status == OrderStatus.placed).length;
        final kitchenCount = orders.where((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.preparing).length;
        final readyCount = orders.where((o) => o.status == OrderStatus.ready).length;
        final historyCount = orders.where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.uncollected || o.status == OrderStatus.cancelled).length;

        final counts = [activeCount, placedCount, kitchenCount, readyCount, historyCount];

        return Scaffold(
          backgroundColor: const Color(0xFF121418),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E222A),
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _vendorProfile?.canteenName ?? 'Canteen Crave Vendor',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  _vendorProfile?.campusId ?? 'Campus Order Pipeline',
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
            actions: [
              // Store Open/Close Toggle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _isStoreOpen
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isStoreOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: _isStoreOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isStoreOpen ? 'OPEN' : 'PAUSED',
                      style: TextStyle(
                        color: _isStoreOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: _isStoreOpen,
                        activeThumbColor: const Color(0xFF10B981),
                        activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                        onChanged: _toggleStoreStatus,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFFFF6B00),
              unselectedLabelColor: Colors.white60,
              indicatorColor: const Color(0xFFFF6B00),
              indicatorWeight: 3,
              tabs: List.generate(_tabLabels.length, (i) {
                final label = _tabLabels[i];
                final count = counts[i];
                return Tab(
                  child: Row(
                    children: [
                      Text(label),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: i == 1
                                ? const Color(0xFF3B82F6)
                                : i == 2
                                    ? const Color(0xFFFF9800)
                                    : i == 3
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF2C3240),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isSimulating ? null : _simulateIncomingOrder,
            backgroundColor: const Color(0xFF3B82F6),
            icon: _isSimulating
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: const Text(
              'Simulate Order',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            tooltip: 'Simulate a new incoming student order into live stream',
          ),
          body: TabBarView(
            controller: _tabController,
            children: List.generate(_tabLabels.length, (tabIdx) {
              final filtered = _filterOrders(orders, tabIdx);

              if (filtered.isEmpty) {
                return _buildEmptyOrdersState(tabIdx);
              }

              return RefreshIndicator(
                onRefresh: () async => setState(() {}),
                color: const Color(0xFFFF6B00),
                backgroundColor: const Color(0xFF1E222A),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    return LiveOrderCard(
                      order: filtered[i],
                      vendorId: widget.vendorId,
                    );
                  },
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildEmptyOrdersState(int tabIndex) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E222A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders in ${_tabLabels[tabIndex]}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Live orders placed by students stream directly into your kitchen screen.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSimulating ? null : _simulateIncomingOrder,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text('Simulate New Student Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            ),
          ],
        ),
      ),
    );
  }
}

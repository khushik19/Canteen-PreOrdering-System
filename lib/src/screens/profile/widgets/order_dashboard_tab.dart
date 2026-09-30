import 'package:flutter/material.dart';
import '../../../core/widgets/widgets.dart';
import '../../../repositories/order_repository.dart'; // Person B's repository

class OrderDashboardTab extends StatelessWidget {
  const OrderDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepository = OrderRepository(); // consider injecting via Provider
    final userId = 'CURRENT_USER_ID'; // replace with real auth state from Person A

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Live Orders'),
              Tab(text: 'Past Orders'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OrderList(
                  stream: orderRepository.watchLiveOrders(userId),
                  emptyTitle: 'No live orders',
                  emptySubtitle: 'Orders you place will show up here.',
                ),
                _OrderList(
                  stream: orderRepository.watchPastOrders(userId),
                  emptyTitle: 'No past orders yet',
                  emptySubtitle: 'Your order history will show up here.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final Stream<List<dynamic>> stream; // typed as OrderModel once confirmed with B
  final String emptyTitle;
  final String emptySubtitle;

  const _OrderList({
    required this.stream,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (snapshot.hasError) {
          return ErrorStateWidget(message: snapshot.error.toString());
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderStatusCard(
              orderId: order.id,
              itemsSummary: order.itemsSummary,
              totalAmount: order.totalAmount,
              status: order.status,
              pickupTime:
                  '${order.pickupTime.hour.toString().padLeft(2, '0')}:${order.pickupTime.minute.toString().padLeft(2, '0')}',
              onTap: () {
                // TODO: navigate to order detail screen, if the team builds one
              },
            );
          },
        );
      },
    );
  }
}
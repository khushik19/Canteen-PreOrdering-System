import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../payment/payment_screen.dart';
import 'cart_controller.dart';
import 'cart_theme.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/recommendation_carousel.dart';
import 'widgets/pickup_time_selector.dart';
import 'widgets/bill_details.dart';
import 'widgets/pay_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // TODO: replace with real cart data (persisted via core/storage +
  // Person A's menu data) once that's wired up.
  late final CartController controller = CartController(
    initialItems: [
      CartItemModel(
        id: 'burger',
        name: 'Paneer Burger',
        description: 'Crispy paneer patty with creamy chipotle sauce',
        price: 120,
        imageUrl: 'https://picsum.photos/seed/burger/200',
        cookingTimeMinutes: 5,
      ),
      CartItemModel(
        id: 'maggi',
        name: 'Chilli Cheese Garlic Maggi',
        description: 'Spicy garlic maggi loaded with cheese',
        price: 80,
        imageUrl: 'https://picsum.photos/seed/maggi/200',
        cookingTimeMinutes: 7,
      ),
    ],
  );

  // Prototype data — presentation-only change for this task (per the
  // brief, do not build a real recommendation engine yet). Deliberately
  // framed as pairings that go *with* what's already in the cart rather
  // than a generic product list.
  // TODO: swap for a real contextual-recommendation call based on cart
  // contents once that logic exists (CartController/Repository → here).
  final List<RecommendationItem> completeOrderItems = const [
    RecommendationItem(id: 'fries', name: 'Fries', price: 60, imageUrl: 'https://picsum.photos/seed/fries/200'),
    RecommendationItem(id: 'coldcoffee', name: 'Cold Coffee', price: 70, imageUrl: 'https://picsum.photos/seed/coldcoffee/200'),
    RecommendationItem(id: 'brownie', name: 'Brownie', price: 80, imageUrl: 'https://picsum.photos/seed/brownie/200'),
    RecommendationItem(id: 'chocolateshake', name: 'Chocolate Shake', price: 90, imageUrl: 'https://picsum.photos/seed/shake/200'),
    RecommendationItem(id: 'cookies', name: 'Cookies', price: 50, imageUrl: 'https://picsum.photos/seed/cookies/200'),
    RecommendationItem(id: 'chips', name: 'Chips', price: 30, imageUrl: 'https://picsum.photos/seed/chips/200'),
    RecommendationItem(id: 'cake', name: 'Slice of Cake', price: 70, imageUrl: 'https://picsum.photos/seed/cake/200'),
    RecommendationItem(id: 'lemonade2', name: 'Lemonade', price: 50, imageUrl: 'https://picsum.photos/seed/lemonade2/200'),
  ];

  // TODO: swap for the student's real favourites + order history.
  final List<RecommendationItem> forYouItems = const [
    RecommendationItem(id: 'sandwich', name: 'Indori Sandwich', price: 90, imageUrl: 'https://picsum.photos/seed/sandwich/200', label: '♥ Liked'),
    RecommendationItem(id: 'lemonade', name: 'Lemonade', price: 50, imageUrl: 'https://picsum.photos/seed/lemonade/200', label: '↻ Ordered before'),
    RecommendationItem(id: 'coldcoffee2', name: 'Cold Coffee', price: 70, imageUrl: 'https://picsum.photos/seed/coldcoffee2/200', label: '↻ Ordered before'),
    RecommendationItem(id: 'brownie2', name: 'Brownie', price: 80, imageUrl: 'https://picsum.photos/seed/brownie2/200', label: '♥ Liked'),
    RecommendationItem(id: 'maggi2', name: 'Veg Maggi', price: 70, imageUrl: 'https://picsum.photos/seed/maggi2/200', label: '↻ Ordered before'),
    RecommendationItem(id: 'combo1', name: 'Burger + Fries', price: 170, imageUrl: 'https://picsum.photos/seed/combo1/200', label: 'Your usual', isCombo: true),
    RecommendationItem(id: 'samosa', name: 'Samosa', price: 30, imageUrl: 'https://picsum.photos/seed/samosa/200', label: '♥ Liked'),
    RecommendationItem(id: 'icedtea', name: 'Iced Tea', price: 45, imageUrl: 'https://picsum.photos/seed/icedtea/200', label: '↻ Ordered before'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CartColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.isEmpty) return _buildEmptyState(context);
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => CartItemCard(
                        item: controller.items[i],
                        onIncrease: () => controller.increaseQuantity(controller.items[i].id),
                        onDecrease: () => controller.decreaseQuantity(controller.items[i].id),
                        onToggleFavourite: () => controller.toggleFavourite(controller.items[i].id),
                        onDelete: () => controller.removeItem(controller.items[i].id),
                      ),
                      childCount: controller.items.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildClearCart(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: RecommendationCarousel(
                      title: 'Complete Your Order',
                      items: completeOrderItems,
                      onAdd: controller.addRecommendation,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: RecommendationCarousel(
                      title: 'For You',
                      items: forYouItems,
                      onAdd: controller.addRecommendation,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: PickupTimeSelector(controller: controller),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: BillDetails(items: controller.items, total: controller.subtotal),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: PayButton(
                      total: controller.subtotal,
                      onTap: () => _goToPayment(context),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds an OrderModel from current cart state and hands off to Payment.
  /// TODO: `id` and `userId` should come from the backend/auth once those
  /// exist — this generates a placeholder so the flow is testable now.
  void _goToPayment(BuildContext context) {
    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current-user', // TODO: from auth_service (Person A)
      items: List.of(controller.items),
      total: controller.subtotal,
      placedAt: DateTime.now(),
      pickupTime: controller.pickupMode == PickupMode.scheduled && controller.scheduledTime != null
          ? _resolveScheduledDateTime(controller.scheduledTime!)
          : DateTime.now().add(Duration(minutes: controller.asapEstimateMinutes)),
      isAsap: controller.pickupMode == PickupMode.asap,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          order: order,
          // TODO: pull from the logged-in student's profile.
          studentName: 'Student',
          studentEmail: 'student@example.com',
          studentPhone: '9999999999',
        ),
      ),
    );
  }

  DateTime _resolveScheduledDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      child: Row(
        children: [
          const Text(
            'Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CartColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '${controller.itemCount} items',
              key: ValueKey(controller.itemCount),
              style: const TextStyle(fontSize: 13, color: CartColors.textSecondary),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.close, color: CartColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildClearCart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => _confirmClearCart(context),
          child: const Text('Clear cart',
              style: TextStyle(color: CartColors.accent, fontSize: 13)),
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CartColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Clear your cart?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              const Text('All items will be removed from your cart.',
                  style: TextStyle(color: CartColors.textSecondary)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: CartColors.accent),
                      onPressed: () {
                        controller.clearCart();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear cart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 40, color: CartColors.textSecondary),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: CartColors.textPrimary)),
          const SizedBox(height: 4),
          const Text("Hungry? Let's fix that.",
              style: TextStyle(color: CartColors.textSecondary)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {}, // TODO: navigate to Menu (Person A)
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }
}
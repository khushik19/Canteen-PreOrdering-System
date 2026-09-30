import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/widgets.dart';
import '../../models/flash_sale_model.dart';
import 'flash_sale_controller.dart';
import 'widgets/flash_sale_claim_sheet.dart';

class FlashSaleScreen extends StatelessWidget {
  final String campusId;
  final String currentUserId;

  const FlashSaleScreen({
    super.key,
    required this.campusId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FlashSaleController()..watchCampus(campusId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Flash Sale')),
        body: Consumer<FlashSaleController>(
          builder: (context, controller, _) {
            switch (controller.state) {
              case FlashSaleLoadState.loading:
                return const LoadingIndicator(message: 'Loading flash sales...');
              case FlashSaleLoadState.error:
                return ErrorStateWidget(
                  message: controller.errorMessage ?? 'Failed to load flash sales.',
                  onRetry: () => controller.watchCampus(campusId),
                );
              case FlashSaleLoadState.loaded:
                if (controller.sales.isEmpty) {
                  return const EmptyState(
                    icon: Icons.local_fire_department_outlined,
                    title: 'No flash sales right now',
                    subtitle: 'Check back later for discounted unclaimed orders.',
                  );
                }
                return _FlashSaleGrid(
                  sales: controller.sales,
                  claimingId: controller.claimingId,
                  onTapSale: (sale) => _openClaimSheet(context, sale),
                );
            }
          },
        ),
      ),
    );
  }

  void _openClaimSheet(BuildContext context, FlashSaleModel sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FlashSaleClaimSheet(sale: sale, currentUserId: currentUserId),
    );
  }
}

class _FlashSaleGrid extends StatelessWidget {
  final List<FlashSaleModel> sales;
  final String? claimingId;
  final void Function(FlashSaleModel) onTapSale;

  const _FlashSaleGrid({
    required this.sales,
    required this.claimingId,
    required this.onTapSale,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return ItemCard(
          imageUrl: sale.imageUrl ?? 'https://placehold.co/300x200',
          name: sale.itemName,
          price: sale.discountedPrice,
          originalPrice: sale.originalPrice,
          discountPercent: sale.discountPercent,
          onTap: () => onTapSale(sale),
        );
      },
    );
  }
}
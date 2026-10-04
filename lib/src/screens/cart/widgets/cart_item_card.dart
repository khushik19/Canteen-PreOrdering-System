import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';
import '../cart_theme.dart';
import 'quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggleFavourite;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggleFavourite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: CartColors.accent,
          borderRadius: BorderRadius.circular(CartRadii.card),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CartColors.cardSurface,
          borderRadius: BorderRadius.circular(CartRadii.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: CartColors.accentSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: CartColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.quantity > 1
                            ? '₹${item.lineTotal.toStringAsFixed(0)}'
                            : '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CartColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: CartColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      QuantitySelector(
                        quantity: item.quantity,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                      ),
                      const Spacer(),
                      _FavouriteHeart(
                        isFavourite: item.isFavourite,
                        onTap: onToggleFavourite,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavouriteHeart extends StatefulWidget {
  final bool isFavourite;
  final VoidCallback onTap;

  const _FavouriteHeart({required this.isFavourite, required this.onTap});

  @override
  State<_FavouriteHeart> createState() => _FavouriteHeartState();
}

class _FavouriteHeartState extends State<_FavouriteHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.0,
    upperBound: 0.25,
  );
  bool _showSparkle = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
  _controller.forward().then((_) => _controller.reverse());

  if (!widget.isFavourite) {
    setState(() {
      _showSparkle = true;
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        setState(() {
          _showSparkle = false;
        });
      }
    });
  }

  widget.onTap();
},
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: 1 + _controller.value,
          child: child,
        ),
        child: Stack(
  clipBehavior: Clip.none,
  children: [
    Icon(
      widget.isFavourite ? Icons.favorite : Icons.favorite_border,
      size: 20,
      color: widget.isFavourite
          ? CartColors.accent
          : CartColors.textSecondary.withOpacity(0.6),
    ),

    if (_showSparkle)
      const Positioned(
        top: -7,
        right: -7,
        child: Icon(
          Icons.auto_awesome,
          size: 11,
          color: CartColors.accent,
        ),
      ),
  ],
),
      ),
    );
  }
}
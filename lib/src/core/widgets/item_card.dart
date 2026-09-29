import 'package:flutter/material.dart';
import 'status_badge.dart';

/// Generic card for displaying a food item.
/// Reused across Home, Menu, Favourites, and Flash Sale.
class ItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final double? originalPrice; // set this to show a strikethrough (flash sale)
  final int? discountPercent;  // shows a StatusBadge.discount() tag if set
  final bool isFavourite;
  final VoidCallback? onTap;
  final VoidCallback? onFavouriteToggle;

  const ItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.isFavourite = false,
    this.onTap,
    this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.3,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.fastfood, size: 32),
                    ),
                  ),
                ),
                if (discountPercent != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: StatusBadge.discount(discountPercent!),
                  ),
                if (onFavouriteToggle != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        isFavourite ? Icons.favorite : Icons.favorite_border,
                        color: isFavourite ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: onFavouriteToggle,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'â‚¹${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          'â‚¹${originalPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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


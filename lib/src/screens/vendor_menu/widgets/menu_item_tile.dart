import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/menu_item_model.dart';
import '../../../repositories/vendor_repository.dart';

class MenuItemTile extends StatefulWidget {
  final MenuItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<MenuItemTile> {
  final _vendorRepository = VendorRepository();
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.item.isAvailable;
  }

  @override
  void didUpdateWidget(covariant MenuItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isAvailable != widget.item.isAvailable) {
      _isAvailable = widget.item.isAvailable;
    }
  }

  Future<void> _toggleAvailability(bool val) async {
    setState(() => _isAvailable = val);
    try {
      await _vendorRepository.toggleMenuItemAvailability(widget.item.id, val);
    } catch (_) {}
  }

  void _showQuickCookingTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E222A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFFFFB300)),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Cooking Time: ${widget.item.name}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Adjust preparation time based on current kitchen load/rush',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [5, 10, 15, 20, 25, 30, 45, 60].map((mins) {
                  final isCurrent = widget.item.cookingTimeMinutes == mins;
                  return ChoiceChip(
                    label: Text('$mins mins'),
                    selected: isCurrent,
                    selectedColor: const Color(0xFFFFB300),
                    backgroundColor: const Color(0xFF121418),
                    labelStyle: TextStyle(
                      color: isCurrent ? Colors.black : Colors.white70,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) async {
                      if (selected) {
                        Navigator.pop(ctx);
                        await _vendorRepository.updateCookingTime(widget.item.id, mins);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('⚡ Cooking time set to $mins mins!'),
                              backgroundColor: const Color(0xFF10B981),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.item.imageUrl != null && widget.item.imageUrl!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAvailable ? const Color(0xFF2C3240) : Colors.redAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Dietary Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: Color(0xFF121418)),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: widget.item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(
                          widget.item.isVeg ? Icons.eco : Icons.kebab_dining,
                          color: widget.item.isVeg ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 26,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        widget.item.isVeg ? Icons.eco : Icons.kebab_dining,
                        color: widget.item.isVeg ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 26,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Title, Category, Prep Time & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.name,
                        style: TextStyle(
                          color: _isAvailable ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: _isAvailable ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3240),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.item.category,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Interactive Cooking Time Badge
                    GestureDetector(
                      onTap: _showQuickCookingTimePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 12, color: Color(0xFFFFB300)),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.item.cookingTimeMinutes}m',
                              style: const TextStyle(color: Color(0xFFFFB300), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${widget.item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // In-Stock Switch and Options Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isAvailable ? 'In Stock' : 'Sold Out',
                    style: TextStyle(
                      color: _isAvailable ? const Color(0xFF10B981) : Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: _isAvailable,
                      activeThumbColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                      onChanged: _toggleAvailability,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white70),
                    onPressed: widget.onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    tooltip: 'Edit Item',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: widget.onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    tooltip: 'Delete Item',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

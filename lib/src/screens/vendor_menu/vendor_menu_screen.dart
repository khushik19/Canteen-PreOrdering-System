import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/vendor_repository.dart';
import 'add_edit_menu_item_screen.dart';
import 'widgets/menu_item_tile.dart';

class VendorMenuScreen extends StatefulWidget {
  final String vendorId;
  final String campusId;

  const VendorMenuScreen({
    super.key,
    required this.vendorId,
    this.campusId = 'Main Campus',
  });

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  final _vendorRepository = VendorRepository();
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSeeding = false;

  final List<String> _categories = ['All', 'Meals', 'Snacks', 'Beverages', 'Desserts', 'Breakfast', 'Combos'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _seedSampleMenu() async {
    setState(() => _isSeeding = true);
    final now = DateTime.now();

    final sampleDishes = [
      MenuItemModel(
        id: '',
        vendorId: widget.vendorId,
        campusId: widget.campusId,
        name: 'Paneer Butter Masala Combo',
        description: 'Served with 3 butter rotis, jeera rice & fresh salad',
        price: 130.0,
        category: 'Meals',
        isAvailable: true,
        cookingTimeMinutes: 15,
        isVeg: true,
        imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&q=80',
        createdAt: now,
      ),
      MenuItemModel(
        id: '',
        vendorId: widget.vendorId,
        campusId: widget.campusId,
        name: 'Crispy Veg Burger',
        description: 'Loaded with cheese, lettuce, tomato & mayo patty',
        price: 70.0,
        category: 'Snacks',
        isAvailable: true,
        cookingTimeMinutes: 10,
        isVeg: true,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
        createdAt: now,
      ),
      MenuItemModel(
        id: '',
        vendorId: widget.vendorId,
        campusId: widget.campusId,
        name: 'Masala Dosa with Chutney',
        description: 'Crispy golden dosa with potato masala & piping hot sambar',
        price: 60.0,
        category: 'Breakfast',
        isAvailable: true,
        cookingTimeMinutes: 10,
        isVeg: true,
        imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=500&q=80',
        createdAt: now,
      ),
      MenuItemModel(
        id: '',
        vendorId: widget.vendorId,
        campusId: widget.campusId,
        name: 'Iced Cold Coffee with Ice Cream',
        description: 'Rich creamy blend with chocolate drizzle',
        price: 50.0,
        category: 'Beverages',
        isAvailable: true,
        cookingTimeMinutes: 5,
        isVeg: true,
        imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500&q=80',
        createdAt: now,
      ),
      MenuItemModel(
        id: '',
        vendorId: widget.vendorId,
        campusId: widget.campusId,
        name: 'Chole Bhature (2 Pcs)',
        description: 'Authentic Punjabi chole with fluffy fried bhature & pickle',
        price: 90.0,
        category: 'Meals',
        isAvailable: true,
        cookingTimeMinutes: 20,
        isVeg: true,
        createdAt: now,
      ),
      MenuItemModel(
        id: '',
        vendorId: widget.vendorId,
        campusId: widget.campusId,
        name: 'Schezwan Fried Rice',
        description: 'Spicy wok-tossed rice with crunchy veggies & sauce',
        price: 85.0,
        category: 'Meals',
        isAvailable: true,
        cookingTimeMinutes: 15,
        isVeg: true,
        createdAt: now,
      ),
    ];

    try {
      for (final dish in sampleDishes) {
        await _vendorRepository.addMenuItem(dish);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ 6 Canteen Dishes successfully loaded to your menu!'),
            backgroundColor: Color(0xFF10B981),
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
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _confirmDelete(MenuItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Menu Item?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${item.name}" from your canteen menu?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _vendorRepository.deleteMenuItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted'), backgroundColor: Colors.redAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222A),
        elevation: 0,
        title: const Text(
          'Menu Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFFF6B00), size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditMenuItemScreen(
                    vendorId: widget.vendorId,
                    campusId: widget.campusId,
                  ),
                ),
              );
            },
            tooltip: 'Add Dish',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditMenuItemScreen(
                vendorId: widget.vendorId,
                campusId: widget.campusId,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFFFF6B00),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Dish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: const Color(0xFF1E222A),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search dishes, snacks, beverages...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B00)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF121418),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final isSel = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFF6B00) : const Color(0xFF121418),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFF6B00) : const Color(0xFF2C3240),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Menu Items Stream
          Expanded(
            child: StreamBuilder<List<MenuItemModel>>(
              stream: _vendorRepository.streamMenuItems(widget.vendorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
                }

                final allItems = snapshot.data ?? [];
                final filtered = allItems.where((it) {
                  final matchesCat = _selectedCategory == 'All' || it.category.toLowerCase() == _selectedCategory.toLowerCase();
                  final matchesQuery = _searchQuery.isEmpty ||
                      it.name.toLowerCase().contains(_searchQuery) ||
                      it.category.toLowerCase().contains(_searchQuery);
                  return matchesCat && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
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
                            child: const Icon(Icons.fastfood_outlined, size: 50, color: Colors.white30),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            allItems.isEmpty ? 'No menu items in your canteen yet' : 'No matching dishes found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            allItems.isEmpty
                                ? 'Add your dishes manually or load our sample canteen catalog to get started instantly.'
                                : 'Try changing your search query or category filter.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          if (allItems.isEmpty) ...[
                            ElevatedButton.icon(
                              onPressed: _isSeeding ? null : _seedSampleMenu,
                              icon: const Icon(Icons.auto_awesome, color: Colors.black),
                              label: _isSeeding
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                  : const Text('Load Demo Canteen Menu (6 Dishes)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB300),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditMenuItemScreen(
                                      vendorId: widget.vendorId,
                                      campusId: widget.campusId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, color: Color(0xFFFF6B00)),
                              label: const Text('Add Single Dish Manually', style: TextStyle(color: Color(0xFFFF6B00))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFF6B00)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    return MenuItemTile(
                      item: item,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditMenuItemScreen(
                              vendorId: widget.vendorId,
                              campusId: widget.campusId,
                              itemToEdit: item,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

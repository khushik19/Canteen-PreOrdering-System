import 'package:flutter/material.dart';
import '../../models/stock_item_model.dart';
import '../../repositories/stock_repository.dart';
import 'add_edit_stock_dialog.dart';
import 'widgets/stock_counter_widget.dart';

class VendorStockScreen extends StatefulWidget {
  final String vendorId;

  const VendorStockScreen({super.key, required this.vendorId});

  @override
  State<VendorStockScreen> createState() => _VendorStockScreenState();
}

class _VendorStockScreenState extends State<VendorStockScreen> {
  final _stockRepository = StockRepository();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _filterLowStockOnly = false;
  bool _isSeeding = false;

  final List<String> _categories = [
    'All',
    'Packaged Snacks',
    'Cold Beverages',
    'Chocolates & Candies',
    'Bakery & Biscuits',
    'Instant Noodles',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddStockDialog([StockItemModel? item]) {
    showDialog(
      context: context,
      builder: (_) => AddEditStockDialog(
        vendorId: widget.vendorId,
        itemToEdit: item,
      ),
    );
  }

  Future<void> _seedSampleStock() async {
    setState(() => _isSeeding = true);
    final now = DateTime.now();

    final sampleItems = [
      StockItemModel(
        id: '',
        vendorId: widget.vendorId,
        name: 'Lays Classic Salted 50g',
        category: 'Packaged Snacks',
        price: 20.0,
        quantity: 28,
        lowStockThreshold: 8,
        isAvailable: true,
        updatedAt: now,
      ),
      StockItemModel(
        id: '',
        vendorId: widget.vendorId,
        name: 'Coca-Cola Can 300ml',
        category: 'Cold Beverages',
        price: 40.0,
        quantity: 15,
        lowStockThreshold: 5,
        isAvailable: true,
        updatedAt: now,
      ),
      StockItemModel(
        id: '',
        vendorId: widget.vendorId,
        name: 'Cadbury Dairy Milk Silk 60g',
        category: 'Chocolates & Candies',
        price: 80.0,
        quantity: 4, // Trigger low stock!
        lowStockThreshold: 6,
        isAvailable: true,
        updatedAt: now,
      ),
      StockItemModel(
        id: '',
        vendorId: widget.vendorId,
        name: 'Red Bull Energy Drink 250ml',
        category: 'Cold Beverages',
        price: 125.0,
        quantity: 12,
        lowStockThreshold: 4,
        isAvailable: true,
        updatedAt: now,
      ),
      StockItemModel(
        id: '',
        vendorId: widget.vendorId,
        name: 'Maggi 2-Minute Noodles (Pack)',
        category: 'Instant Noodles',
        price: 15.0,
        quantity: 45,
        lowStockThreshold: 10,
        isAvailable: true,
        updatedAt: now,
      ),
      StockItemModel(
        id: '',
        vendorId: widget.vendorId,
        name: 'Oreo Vanilla Cream 120g',
        category: 'Bakery & Biscuits',
        price: 35.0,
        quantity: 0, // Out of stock demo!
        lowStockThreshold: 5,
        isAvailable: false,
        updatedAt: now,
      ),
    ];

    try {
      for (final item in sampleItems) {
        await _stockRepository.addStockItem(item);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ 6 Packaged Stock items added to your canteen inventory!'),
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

  void _confirmDelete(StockItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E222A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Stock Item?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${item.name}" from inventory tracking?',
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
              await _stockRepository.deleteStockItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock item deleted'), backgroundColor: Colors.redAccent),
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
          'Packaged Stock & Snacks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: Color(0xFFFF6B00), size: 28),
            onPressed: () => _openAddStockDialog(),
            tooltip: 'Add Stock',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddStockDialog(),
        backgroundColor: const Color(0xFFFF6B00),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Stock Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter Header
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
                    hintText: 'Search packaged snacks, drinks, biscuits...',
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

                // Category list
                SizedBox(
                  height: 32,
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFF6B00) : const Color(0xFF121418),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSel ? const Color(0xFFFF6B00) : const Color(0xFF2C3240)),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Low Stock Filter
                Row(
                  children: [
                    FilterChip(
                      label: const Text('⚠️ Low & Out-of-Stock Alerts Only'),
                      labelStyle: TextStyle(
                        color: _filterLowStockOnly ? Colors.white : Colors.white70,
                        fontSize: 11,
                        fontWeight: _filterLowStockOnly ? FontWeight.bold : FontWeight.normal,
                      ),
                      selected: _filterLowStockOnly,
                      selectedColor: const Color(0xFFFFB300),
                      backgroundColor: const Color(0xFF121418),
                      checkmarkColor: Colors.black,
                      onSelected: (val) => setState(() => _filterLowStockOnly = val),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stock Items List Stream
          Expanded(
            child: StreamBuilder<List<StockItemModel>>(
              stream: _stockRepository.streamStockItems(widget.vendorId),
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
                  final matchesLow = !_filterLowStockOnly || it.isLowStock || it.isOutOfStock;
                  return matchesCat && matchesQuery && matchesLow;
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
                            child: const Icon(Icons.inventory_2_outlined, size: 50, color: Colors.white30),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            allItems.isEmpty ? 'No packaged stock tracked yet' : 'No matching inventory items',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            allItems.isEmpty
                                ? 'Track snacks, bottled drinks & packaged food with live stock counters.'
                                : 'Try changing your search query or category filter.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          if (allItems.isEmpty) ...[
                            ElevatedButton.icon(
                              onPressed: _isSeeding ? null : _seedSampleStock,
                              icon: const Icon(Icons.auto_awesome, color: Colors.black),
                              label: _isSeeding
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                  : const Text('Load Demo Packaged Stock (6 Items)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB300),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _openAddStockDialog(),
                              icon: const Icon(Icons.add, color: Color(0xFFFF6B00)),
                              label: const Text('Add Single Stock Item Manually', style: TextStyle(color: Color(0xFFFF6B00))),
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
                    return StockCounterWidget(
                      item: item,
                      onEdit: () => _openAddStockDialog(item),
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

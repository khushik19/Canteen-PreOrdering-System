import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/vendor_repository.dart';
import 'widgets/cooking_time_dropdown.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final String vendorId;
  final String campusId;
  final MenuItemModel? itemToEdit;

  const AddEditMenuItemScreen({
    super.key,
    required this.vendorId,
    required this.campusId,
    this.itemToEdit,
  });

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Meals';
  final List<String> _categories = ['Meals', 'Snacks', 'Beverages', 'Desserts', 'Breakfast', 'Combos'];

  int _cookingTimeMinutes = 15;
  bool _isVeg = true;
  bool _isAvailable = true;
  bool _isLoading = false;

  final _vendorRepository = VendorRepository();

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final it = widget.itemToEdit!;
      _nameController.text = it.name;
      _descController.text = it.description;
      _priceController.text = it.price.toStringAsFixed(0);
      _imageUrlController.text = it.imageUrl ?? '';
      _selectedCategory = it.category;
      _cookingTimeMinutes = it.cookingTimeMinutes;
      _isVeg = it.isVeg;
      _isAvailable = it.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final now = DateTime.now();

      if (widget.itemToEdit == null) {
        // Add new
        final newItem = MenuItemModel(
          id: '',
          vendorId: widget.vendorId,
          campusId: widget.campusId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
          category: _selectedCategory,
          isAvailable: _isAvailable,
          cookingTimeMinutes: _cookingTimeMinutes,
          isVeg: _isVeg,
          createdAt: now,
          updatedAt: now,
        );
        await _vendorRepository.addMenuItem(newItem);
      } else {
        // Update existing
        final updated = widget.itemToEdit!.copyWith(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
          category: _selectedCategory,
          isAvailable: _isAvailable,
          cookingTimeMinutes: _cookingTimeMinutes,
          isVeg: _isVeg,
          updatedAt: now,
        );
        await _vendorRepository.updateMenuItem(updated);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.itemToEdit == null ? 'Menu item created!' : 'Menu item updated!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.itemToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Menu Item' : 'Add New Item',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Item Name
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g. Schezwan Fried Rice, Paneer Roll',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    prefixIcon: const Icon(Icons.restaurant_menu, color: Color(0xFFFF6B00)),
                    filled: true,
                    fillColor: const Color(0xFF1E222A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Item name is required',
                ),
                const SizedBox(height: 16),

                // Category & Price Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                        dropdownColor: const Color(0xFF1E222A),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          filled: true,
                          fillColor: const Color(0xFF1E222A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Price (₹)',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Text('₹', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E222A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter price';
                          if (double.tryParse(v) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cooking Time Dropdown (Person C core feature)
                CookingTimeDropdown(
                  selectedMinutes: _cookingTimeMinutes,
                  onChanged: (mins) => setState(() => _cookingTimeMinutes = mins),
                ),
                const SizedBox(height: 16),

                // Dietary Veg / Non-Veg Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E222A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isVeg ? Icons.eco : Icons.kebab_dining,
                            color: _isVeg ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isVeg ? 'Vegetarian Dish' : 'Non-Vegetarian Dish',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isVeg,
                        activeThumbColor: const Color(0xFF10B981),
                        activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                        inactiveThumbColor: const Color(0xFFEF4444),
                        inactiveTrackColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        onChanged: (val) => setState(() => _isVeg = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description / Ingredients (Optional)',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: const Color(0xFF1E222A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                // Image URL
                TextFormField(
                  controller: _imageUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Image Web URL (Optional)',
                    hintText: 'https://...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    prefixIcon: const Icon(Icons.image_outlined, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1E222A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 28),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          isEdit ? 'Update Menu Item' : 'Add to Canteen Menu',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

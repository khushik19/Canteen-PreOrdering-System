import 'package:flutter/material.dart';
import '../../models/stock_item_model.dart';
import '../../repositories/stock_repository.dart';

class AddEditStockDialog extends StatefulWidget {
  final String vendorId;
  final StockItemModel? itemToEdit;

  const AddEditStockDialog({
    super.key,
    required this.vendorId,
    this.itemToEdit,
  });

  @override
  State<AddEditStockDialog> createState() => _AddEditStockDialogState();
}

class _AddEditStockDialogState extends State<AddEditStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _thresholdController = TextEditingController();

  String _selectedCategory = 'Packaged Snacks';
  final List<String> _categories = ['Packaged Snacks', 'Cold Beverages', 'Chocolates & Candies', 'Bakery & Biscuits', 'Instant Noodles'];

  bool _isLoading = false;
  final _stockRepository = StockRepository();

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final it = widget.itemToEdit!;
      _nameController.text = it.name;
      _priceController.text = it.price.toStringAsFixed(0);
      _qtyController.text = it.quantity.toString();
      _thresholdController.text = it.lowStockThreshold.toString();
      _selectedCategory = it.category;
    } else {
      _qtyController.text = '20';
      _thresholdController.text = '5';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
      final threshold = int.tryParse(_thresholdController.text.trim()) ?? 5;
      final now = DateTime.now();

      if (widget.itemToEdit == null) {
        final newItem = StockItemModel(
          id: '',
          vendorId: widget.vendorId,
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: price,
          quantity: qty,
          lowStockThreshold: threshold,
          isAvailable: qty > 0,
          updatedAt: now,
        );
        await _stockRepository.addStockItem(newItem);
      } else {
        final updated = widget.itemToEdit!.copyWith(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          price: price,
          quantity: qty,
          lowStockThreshold: threshold,
          isAvailable: qty > 0,
          updatedAt: now,
        );
        await _stockRepository.updateStockItem(updated);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.itemToEdit != null;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E222A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdit ? 'Edit Stock Item' : 'Add Packaged Stock',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Item Name & Size',
                  hintText: 'e.g. Lays 50g, Coca-Cola 300ml',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: const Color(0xFF121418),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categories.contains(_selectedCategory) ? _selectedCategory : _categories.first,
                dropdownColor: const Color(0xFF1E222A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: const Color(0xFF121418),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Price (₹)',
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        filled: true,
                        fillColor: const Color(0xFF121418),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) => v != null && double.tryParse(v) != null ? null : 'Invalid',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Initial Qty',
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        filled: true,
                        fillColor: const Color(0xFF121418),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) => v != null && int.tryParse(v) != null ? null : 'Invalid',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _thresholdController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Low Stock Alert Threshold',
                  hintText: 'Alert when qty <= this value',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: const Color(0xFF121418),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
          child: _isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isEdit ? 'Update' : 'Add Item', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

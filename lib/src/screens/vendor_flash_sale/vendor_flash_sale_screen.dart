import 'package:flutter/material.dart';
import '../../core/widgets/widgets.dart';

class VendorFlashSaleScreen extends StatefulWidget {
  final String vendorId;
  const VendorFlashSaleScreen({super.key, required this.vendorId});

  @override
  State<VendorFlashSaleScreen> createState() => _VendorFlashSaleScreenState();
}

class _VendorFlashSaleScreenState extends State<VendorFlashSaleScreen> {
  int _thresholdMinutes = 15;
  int _discountPercent = 30;
  bool _isSaving = false;

  // Persistence not wired up yet — add a small VendorFlashSaleRepository
  // once the team confirms where vendor settings should live (coordinate with C).
  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500)); // placeholder
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flash sale settings saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flash Sale Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No-Pickup Threshold', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              'How long after an order is ready, with no contact, before it goes on flash sale.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Slider(
              value: _thresholdMinutes.toDouble(), min: 5, max: 60, divisions: 11,
              label: '$_thresholdMinutes min',
              onChanged: (value) => setState(() => _thresholdMinutes = value.round()),
            ),
            const SizedBox(height: 20),
            const Text('Default Discount %', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Slider(
              value: _discountPercent.toDouble(), min: 10, max: 70, divisions: 12,
              label: '$_discountPercent%',
              onChanged: (value) => setState(() => _discountPercent = value.round()),
            ),
            const Spacer(),
            PrimaryButton(label: 'Save Settings', isLoading: _isSaving, onPressed: _saveSettings, width: double.infinity),
          ],
        ),
      ),
    );
  }
}
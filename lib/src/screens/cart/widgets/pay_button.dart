import 'dart:ui';
import 'package:flutter/material.dart';
import '../cart_theme.dart';

class PayButton extends StatelessWidget {
  final double total;
  final String label;
  final VoidCallback onTap;

  const PayButton({
    super.key,
    required this.total,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CartRadii.button),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CartColors.glassDark.withOpacity(0.68),
                  CartColors.glassDark.withOpacity(0.78),
                ],
              ),
              borderRadius: BorderRadius.circular(CartRadii.button),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payy',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                Text('₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
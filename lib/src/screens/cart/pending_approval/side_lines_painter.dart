import 'package:flutter/material.dart';
import '../cart_theme.dart';

/// Very subtle hand-drawn-feeling curves along both edges — static, cheap
/// to paint once, no animation. Deliberately understated per the brief
/// ("barely there", not a decorative border).
class SideLinesPainter extends CustomPainter {
  const SideLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CartColors.textPrimary.withOpacity(0.06)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final leftPath = Path()
      ..moveTo(size.width * 0.06, size.height * 0.08)
      ..quadraticBezierTo(size.width * 0.01, size.height * 0.4, size.width * 0.05, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.09, size.height * 0.75, size.width * 0.04, size.height * 0.94);

    final rightPath = Path()
      ..moveTo(size.width * 0.94, size.height * 0.08)
      ..quadraticBezierTo(size.width * 0.99, size.height * 0.4, size.width * 0.95, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.91, size.height * 0.75, size.width * 0.96, size.height * 0.94);

    canvas.drawPath(leftPath, paint);
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant SideLinesPainter oldDelegate) => false;
}
import 'dart:math';
import 'package:flutter/material.dart';
import '../cart_theme.dart';
import 'food_states.dart';
import 'food_visual.dart';

/// The fixed interactive control — always [miniBurger] — that wanders
/// between random safe destinations (not a fixed repeating path) and
/// triggers a food transition on tap. Owns a single lightweight
/// AnimationController that restarts itself toward a new random
/// destination each time it arrives, so the parent screen never needs to
/// rebuild for this widget's motion.
class FloatingBurger extends StatefulWidget {
  final bool isFrozen;
  final VoidCallback onTap;

  const FloatingBurger({super.key, required this.isFrozen, required this.onTap});

  @override
  State<FloatingBurger> createState() => _FloatingBurgerState();
}

class _FloatingBurgerState extends State<FloatingBurger> with SingleTickerProviderStateMixin {
  // Safe wander bounds — well clear of the header text, order info,
  // timeline, countdown and Cancel/Proceed buttons, which all live in the
  // center content column.
  static const _xRange = (-0.72, 0.72);
  static const _yRange = (-0.8, 0.5);
  static const _rotationRange = (-0.09, 0.09);
  static const _scaleRange = (0.92, 1.08);

  final _rng = Random();
  late final AnimationController _controller;
  late Animation<Alignment> _alignmentAnim;
  late Animation<double> _rotationAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _alignmentAnim = AlwaysStoppedAnimation(_randomAlignment());
    _rotationAnim = AlwaysStoppedAnimation(_randomIn(_rotationRange));
    _scaleAnim = const AlwaysStoppedAnimation(1.0);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !widget.isFrozen) {
        _startNextLeg();
      }
    });
    // Kick off the first leg after the first frame so `context`/size are
    // ready; a short post-frame delay also avoids animating before the
    // screen has settled in.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNextLeg());
  }

  @override
  void didUpdateWidget(covariant FloatingBurger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFrozen && !oldWidget.isFrozen) {
      _controller.stop();
    } else if (!widget.isFrozen && oldWidget.isFrozen) {
      _startNextLeg();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _randomIn((double, double) range) => range.$1 + _rng.nextDouble() * (range.$2 - range.$1);

  Alignment _randomAlignment() => Alignment(_randomIn(_xRange), _randomIn(_yRange));

  void _startNextLeg() {
    if (widget.isFrozen || !mounted) return;
    final from = _alignmentAnim.value;
    final to = _randomAlignment();
    final fromRotation = _rotationAnim.value;
    final toRotation = _randomIn(_rotationRange);
    final fromScale = _scaleAnim.value;
    final toScale = _randomIn(_scaleRange);

    // Vary duration a little so the wandering doesn't feel metronomic.
    _controller.duration = Duration(milliseconds: 3200 + _rng.nextInt(2400));

    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    setState(() {
      _alignmentAnim = AlignmentTween(begin: from, end: to).animate(curved);
      _rotationAnim = Tween(begin: fromRotation, end: toRotation).animate(curved);
      _scaleAnim = Tween(begin: fromScale, end: toScale).animate(curved);
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Align(
        alignment: _alignmentAnim.value,
        child: Transform.rotate(
          angle: _rotationAnim.value,
          child: Transform.scale(scale: _scaleAnim.value, child: child),
        ),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FoodVisual(food: miniBurger, size: 52),
            const SizedBox(height: 2),
            Transform.rotate(
              angle: -0.04,
              child: const Text(
                'tap me!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.6,
                  color: CartColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
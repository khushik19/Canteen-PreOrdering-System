import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../cart_theme.dart';
import '../widgets/pay_button.dart';
import '../../payment/payment_screen.dart';
import 'food_states.dart';
import 'floating_burger.dart';
import 'side_frame.dart';
import 'side_lines_painter.dart';

class PendingApprovalScreen extends StatefulWidget {
  final OrderModel order;
  final String studentName;
  final String studentEmail;
  final String studentPhone;

  const PendingApprovalScreen({
    super.key,
    required this.order,
    required this.studentName,
    required this.studentEmail,
    required this.studentPhone,
  });

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with SingleTickerProviderStateMixin {
  int _foodIndex = 0;
  int _nextIndex = 0;
  bool _isTransitioning = false;

  late OrderStatus _status;
  String? _rejectionReason;

  // If the vendor responds while a food transition is mid-flight, queue
  // it rather than cutting the animation off — applied once the
  // transition's AnimationController reaches `completed`.
  OrderStatus? _pendingStatus;
  String? _pendingReason;

  // Single controller drives the side-frame's upward-conveyor transition
  // (see SideFrame). Target duration ~400ms per the brief.
  late final AnimationController _transitionCtrl;

  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  bool _assetsPrecached = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;

    _transitionCtrl = AnimationController(duration: const Duration(milliseconds: 400), vsync: this)
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        setState(() {
          _foodIndex = _nextIndex;
          _isTransitioning = false;
        });
        _transitionCtrl.reset();
        if (_pendingStatus != null) {
          final status = _pendingStatus!;
          final reason = _pendingReason;
          _pendingStatus = null;
          _pendingReason = null;
          _commitStatus(status, reason: reason);
        }
      });

    _startCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache every food asset once per screen instance so the first tap
    // of each food never stalls on image decode — this is what the brief
    // flags as the likely source of perceived "lag" on Flutter Web.
    if (!_assetsPrecached) {
      _assetsPrecached = true;
      for (final food in foodStates) {
        precacheImage(AssetImage(food.assetPath), context);
      }
      precacheImage(AssetImage(miniBurger.assetPath), context);
    }
  }

  @override
  void dispose() {
    _transitionCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Order status plumbing ────────────────────────────────────────────

  void _startCountdown() {
    _tickCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickCountdown());
  }

  void _tickCountdown() {
    final remaining = widget.order.requestExpiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      _countdownTimer?.cancel();
      _remaining = Duration.zero;
      _applyVendorStatus(OrderStatus.expired);
      return;
    }
    setState(() => _remaining = remaining);
  }

  /// Entry point for a vendor response (from a real backend stream, once
  /// one exists — see the debug gesture below for how this is triggered
  /// today). Defers to after the current food transition if one is
  /// mid-flight, per the "don't abruptly kill the animation" requirement.
  void _applyVendorStatus(OrderStatus status, {String? reason}) {
    if (!mounted) return;
    if (_isTransitioning) {
      _pendingStatus = status;
      _pendingReason = reason;
      return;
    }
    _commitStatus(status, reason: reason);
  }

  void _commitStatus(OrderStatus status, {String? reason}) {
    widget.order.status = status;
    widget.order.rejectionReason = reason;
    setState(() {
      _status = status;
      _rejectionReason = reason;
    });
  }

  // TODO(debug): both of these simulate a vendor response and exist only
  // because there's no backend yet to actually accept/reject an order.
  // Remove once PendingApprovalScreen listens to a real order-status
  // stream/repository, and wire _applyVendorStatus to that instead.
  void _debugSimulateAccept() => _applyVendorStatus(OrderStatus.accepted);
  void _debugSimulateReject() =>
      _applyVendorStatus(OrderStatus.rejected, reason: 'Pickup time unavailable.');

  // ── Food frame interaction ───────────────────────────────────────────

  // Tap lock: `_isTransitioning` is set true synchronously before the
  // animation starts and only cleared when it completes, so rapid taps
  // during the ~400ms transition are no-ops — exactly one transition per
  // tap, never stacked.
  void _onBurgerTap() {
    if (_isTransitioning || _status != OrderStatus.placed) return;
    _nextIndex = (_foodIndex + 1) % foodStates.length;
    setState(() => _isTransitioning = true);
    _transitionCtrl.forward(from: 0);
  }

  // ── Derived order info ───────────────────────────────────────────────

  String get _orderNumber {
    final id = widget.order.id;
    final tail = id.length >= 4 ? id.substring(id.length - 4) : id;
    return 'Order #$tail';
  }

  int get _estimatedPrepMinutes {
    final maxPrep = widget.order.items.fold<int>(
      0,
      (max, item) => item.cookingTimeMinutes > max ? item.cookingTimeMinutes : max,
    );
    return maxPrep > 0 ? maxPrep : 10;
  }

  String _formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _proceedToPay(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          order: widget.order,
          studentName: widget.studentName,
          studentEmail: widget.studentEmail,
          studentPhone: widget.studentPhone,
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: CartColors.background,
        title: const Text('Cancel this request?'),
        content: const Text("The canteen hasn't accepted your order yet. You won't be charged."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep Waiting'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close dialog
              Navigator.of(context).pop(); // leave Pending Approval, back to Cart
            },
            child: const Text('Cancel Request', style: TextStyle(color: CartColors.accent)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
  //
  // Performance note: only the background color actually needs to repaint
  // every transition tick. The center content (header, order info,
  // timeline, cancel button) is built ONCE per setState and passed in as
  // the `child` of the outer AnimatedBuilder, so it is NOT rebuilt on
  // every animation frame. SideFrame listens to `_transitionCtrl`
  // directly via its own internal AnimatedBuilder, so it animates
  // correctly even though the tree around it isn't rebuilding.

  @override
  Widget build(BuildContext context) {
    final theme = foodStates[_foodIndex];
    final content = SafeArea(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(child: CustomPaint(painter: SideLinesPainter())),
          if (_status == OrderStatus.placed)
            Positioned.fill(
              child: SideFrame(
                currentFood: foodStates[_foodIndex],
                nextFood: foodStates[_nextIndex],
                isTransitioning: _isTransitioning,
                transitionAnimation: _transitionCtrl,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _buildCenterContent(theme, context),
          ),
          if (_status == OrderStatus.placed)
            FloatingBurger(isFrozen: _isTransitioning, onTap: _onBurgerTap),
        ],
      ),
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _transitionCtrl,
        builder: (context, child) => Container(
          width: double.infinity,
          height: double.infinity,
          color: Color.lerp(
                foodStates[_foodIndex].tint,
                foodStates[_nextIndex].tint,
                Curves.easeInOut.transform(_transitionCtrl.value),
              ) ??
              foodStates[_foodIndex].tint,
          child: child,
        ),
        child: content,
      ),
    );
  }

  Widget _buildCenterContent(FoodState theme, BuildContext context) {
    switch (_status) {
      case OrderStatus.placed:
        return _buildWaitingContent(theme, context);
      case OrderStatus.accepted:
        return _buildAcceptedContent(context);
      case OrderStatus.rejected:
        return _buildRejectedContent(context);
      case OrderStatus.expired:
        return _buildExpiredContent(context);
      default:
        return _buildWaitingContent(theme, context);
    }
  }

  Widget _buildWaitingContent(FoodState theme, BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onLongPress: _debugSimulateAccept,
              onDoubleTap: _debugSimulateReject,
              child: Column(
                children: [
                  const Text(
                    'Order Request Sent',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: CartColors.textPrimary),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'The canteen is reviewing your order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: CartColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    theme.microcopy,
                    style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: CartColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _divider(),
            const SizedBox(height: 18),
            Text(_orderNumber, style: const TextStyle(fontSize: 11, color: CartColors.textSecondary)),
            const SizedBox(height: 12),
            _buildOrderInfoRow(),
            const SizedBox(height: 10),
            Text(
              'Estimated prep · $_estimatedPrepMinutes min',
              style: const TextStyle(fontSize: 11.5, color: CartColors.textSecondary),
            ),
            const SizedBox(height: 18),
            _divider(),
            const SizedBox(height: 18),
            _buildStatusTimeline(),
            const SizedBox(height: 14),
            _divider(),
            const SizedBox(height: 14),
            _buildCountdown(),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(height: 1, width: 120, color: CartColors.accentSoft);

  Widget _buildAcceptedContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Order Accepted',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: CartColors.textPrimary)),
          const SizedBox(height: 6),
          const Text("You're good to go!", style: TextStyle(fontSize: 13.5, color: CartColors.textSecondary)),
          const SizedBox(height: 28),
          Text(_orderNumber, style: const TextStyle(fontSize: 11, color: CartColors.textSecondary)),
          const SizedBox(height: 12),
          _buildOrderInfoRow(),
          const SizedBox(height: 8),
          Text('Estimated prep · $_estimatedPrepMinutes min',
              style: const TextStyle(fontSize: 12, color: CartColors.textSecondary)),
          const SizedBox(height: 28),
          PayButton(
            total: widget.order.total,
            label: 'Proceed to Pay',
            onTap: () => _proceedToPay(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Couldn't accept this order",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CartColors.textPrimary)),
          const SizedBox(height: 6),
          if (_rejectionReason != null)
            Text(_rejectionReason!, style: const TextStyle(fontSize: 13, color: CartColors.textSecondary)),
          const SizedBox(height: 6),
          const Text('No payment was made.', style: TextStyle(fontSize: 12.5, color: CartColors.textSecondary)),
          const SizedBox(height: 28),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Choose Another Time'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Request Expired',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CartColors.textPrimary)),
          const SizedBox(height: 6),
          const Text("The canteen didn't respond in time.",
              style: TextStyle(fontSize: 13, color: CartColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('No payment was made.', style: TextStyle(fontSize: 12.5, color: CartColors.textSecondary)),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Cart'),
          ),
        ],
      ),
    );
  }

  // ── Order info / status sub-widgets ─────────────────────────────────

  Widget _buildOrderInfoRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _infoColumn('Pickup', widget.order.isAsap ? 'ASAP' : _formatTime(widget.order.pickupTime)),
        const SizedBox(width: 36),
        _infoColumn('Total', '₹${widget.order.total.toStringAsFixed(0)}'),
      ],
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: CartColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: CartColors.textPrimary)),
      ],
    );
  }

  /// Vertical stepper — "Request sent / Waiting for approval / Payment" —
  /// matching the brief's layout sketch more closely than a horizontal row.
  Widget _buildStatusTimeline() {
    const steps = ['Request sent', 'Waiting for approval', 'Payment'];
    const activeIndex = 1; // this screen only renders while "Waiting" is current
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= activeIndex ? CartColors.accent : CartColors.accentSoft,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                steps[i],
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: i <= activeIndex ? FontWeight.w600 : FontWeight.w400,
                  color: i <= activeIndex ? CartColors.textPrimary : CartColors.textSecondary,
                ),
              ),
            ],
          ),
          if (i != steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(width: 1, height: 14, color: CartColors.accentSoft),
            ),
        ],
      ],
    );
  }

  Widget _buildCountdown() {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        'Response window · $minutes:$seconds remaining',
        style: const TextStyle(fontSize: 11.5, color: CartColors.textSecondary),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: TextButton(
        onPressed: () => _confirmCancel(context),
        child: const Text('Cancel Request', style: TextStyle(color: CartColors.textSecondary, fontSize: 13)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../cart_theme.dart';
import '../cart_controller.dart';

/// Pickup Time section: a compact ASAP/Schedule toggle, and — only when
/// Schedule is active — a single inline wheel-style HOUR | MINUTE | AM/PM
/// control (ListWheelScrollView). Replaces the previous two-giant-box
/// layout and the modal ListView time picker. ASAP/Scheduled state and
/// pickup logic still live in CartController, unchanged.
class PickupTimeSelector extends StatefulWidget {
  final CartController controller;

  const PickupTimeSelector({super.key, required this.controller});

  @override
  State<PickupTimeSelector> createState() => _PickupTimeSelectorState();
}

class _PickupTimeSelectorState extends State<PickupTimeSelector> {
  static const _minutes = [0, 15, 30, 45];
  static const _periods = ['AM', 'PM'];
  static const _hours = [9, 10, 11, 12, 1, 2, 3, 4, 5]; // 9 AM – 5 PM, in order

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;
  late final FixedExtentScrollController _periodCtrl;

  late int _hourIndex;
  late int _minuteIndex;
  late int _periodIndex;

  @override
  void initState() {
    super.initState();
    final initial = widget.controller.scheduledTime ?? _roundedNow();
    final hour12 = initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod;
    _hourIndex = _hours.indexOf(hour12);
    if (_hourIndex == -1) _hourIndex = 0;
    _minuteIndex = _minutes.indexOf(initial.minute - (initial.minute % 15));
    if (_minuteIndex == -1) _minuteIndex = 0;
    _periodIndex = initial.period == DayPeriod.am ? 0 : 1;

    _hourCtrl = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minuteIndex);
    _periodCtrl = FixedExtentScrollController(initialItem: _periodIndex);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _roundedNow() {
    final now = DateTime.now();
    final rounded = ((now.minute ~/ 15) + 1) * 15;
    return TimeOfDay(hour: now.hour + rounded ~/ 60, minute: rounded % 60);
  }

  /// Earliest pickup time the kitchen can realistically fulfil: now plus
  /// the longest prep time among items currently in the cart (from
  /// CartItemModel.cookingTimeMinutes), rounded up to the next 15-min slot.
  TimeOfDay _earliestFeasibleTime() {
    final maxPrep = widget.controller.items.fold<int>(
      0,
      (max, item) => item.cookingTimeMinutes > max ? item.cookingTimeMinutes : max,
    );
    final earliest = DateTime.now().add(Duration(minutes: maxPrep));
    final roundedMinute = (earliest.minute / 15).ceil() * 15;
    return TimeOfDay(
      hour: earliest.hour + roundedMinute ~/ 60,
      minute: roundedMinute % 60,
    );
  }

  TimeOfDay _currentSelection() {
    final hour12 = _hours[_hourIndex];
    final period = _periods[_periodIndex];
    final hour24 = period == 'AM'
        ? (hour12 == 12 ? 0 : hour12)
        : (hour12 == 12 ? 12 : hour12 + 12);
    return TimeOfDay(hour: hour24, minute: _minutes[_minuteIndex]);
  }

  /// Canteen closes 5:20 PM, slots are 15-min aligned, and the slot must
  /// also be no earlier than the kitchen can realistically prepare the
  /// current cart.
  bool _isFeasible(TimeOfDay t) {
    final minutesOfDay = t.hour * 60 + t.minute;
    const closing = 17 * 60 + 20;
    if (minutesOfDay + 15 > closing) return false;
    final earliest = _earliestFeasibleTime();
    return minutesOfDay >= earliest.hour * 60 + earliest.minute;
  }

  void _confirm() => widget.controller.setScheduledTime(_currentSelection());

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final selection = _currentSelection();
    final feasible = _isFeasible(selection);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Pickup Time',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: CartColors.textPrimary),
          ),
        ),
        const SizedBox(height: 10),
        _buildModeToggle(controller),
        if (controller.pickupMode == PickupMode.scheduled) ...[
          const SizedBox(height: 12),
          _buildWheel(),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  feasible
                      ? 'Ready by the time you arrive'
                      : 'Kitchen needs a bit more time — pick a later slot',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: feasible ? CartColors.textSecondary : CartColors.accent,
                  ),
                ),
              ),
              TextButton(
                onPressed: feasible ? _confirm : null,
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildModeToggle(CartController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CartColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: '⚡ ASAP · ~${controller.asapEstimateMinutes} min',
              selected: controller.pickupMode == PickupMode.asap,
              onTap: () => controller.setPickupMode(PickupMode.asap),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: controller.pickupMode == PickupMode.scheduled && controller.scheduledTime != null
                  ? '🕐 ${_formatTimeOfDay(controller.scheduledTime!)}'
                  : '🕐 Schedule',
              selected: controller.pickupMode == PickupMode.scheduled,
              onTap: () => controller.setPickupMode(PickupMode.scheduled),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    const itemExtent = 36.0;
    return Container(
      height: itemExtent * 3,
      decoration: BoxDecoration(
        color: CartColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: itemExtent,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: CartColors.accentSoft.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            children: [
              _wheelColumn(
                scrollController: _hourCtrl,
                itemExtent: itemExtent,
                itemCount: _hours.length,
                labelBuilder: (i) => '${_hours[i]}',
                onChanged: (i) => setState(() => _hourIndex = i),
              ),
              _wheelColumn(
                scrollController: _minuteCtrl,
                itemExtent: itemExtent,
                itemCount: _minutes.length,
                labelBuilder: (i) => _minutes[i].toString().padLeft(2, '0'),
                onChanged: (i) => setState(() => _minuteIndex = i),
              ),
              _wheelColumn(
                scrollController: _periodCtrl,
                itemExtent: itemExtent,
                itemCount: _periods.length,
                labelBuilder: (i) => _periods[i],
                onChanged: (i) => setState(() => _periodIndex = i),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wheelColumn({
    required FixedExtentScrollController scrollController,
    required double itemExtent,
    required int itemCount,
    required String Function(int) labelBuilder,
    required void Function(int) onChanged,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: scrollController,
        itemExtent: itemExtent,
        perspective: 0.004,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, i) => Center(
            child: Text(
              labelBuilder(i),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CartColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? CartColors.accentSoft.withOpacity(0.7) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? CartColors.textPrimary : CartColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
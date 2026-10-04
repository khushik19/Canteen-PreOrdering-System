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
  // All hours the canteen is open, in display order. Each value is
  // unambiguous within this window — "9" is only ever 9 AM, "12" is only
  // ever 12 PM, "5" is only ever 5 PM — so AM/PM is fully determined by
  // which hour is picked; it's never an independent choice.
  static const _hours = [9, 10, 11, 12, 1, 2, 3, 4, 5];

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;

  late int _hourIndex;
  late int _minuteIndex;

  /// 5:00 PM and 5:15 PM are the only valid minute values at the 5 PM hour
  /// (5:30/5:45 PM would be past the 5:20 PM close) — every other hour
  /// gets the full set of 15-minute slots.
  List<int> _minutesFor(int hour12) => _toHour24(hour12) == 17 ? const [0, 15] : const [0, 15, 30, 45];

  /// 9, 10, 11 are AM; 12, 1, 2, 3, 4, 5 are PM — the only mapping that's
  /// valid for a canteen open 9:00 AM – 5:20 PM.
  int _toHour24(int hour12) {
    if (hour12 == 9 || hour12 == 10 || hour12 == 11) return hour12;
    return hour12 == 12 ? 12 : hour12 + 12;
  }

  String _periodLabel(int hour12) => (hour12 == 9 || hour12 == 10 || hour12 == 11) ? 'AM' : 'PM';

  List<int> get _minutes => _minutesFor(_hours[_hourIndex]);

  @override
  void initState() {
    super.initState();
    final initial = widget.controller.scheduledTime ?? _roundedNow();
    var hour12 = initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod;
    var minute = initial.minute - (initial.minute % 15);

    // Fall back to opening time if "now" lands outside the canteen's
    // hour set entirely (e.g. testing at 7 AM or 7 PM real time).
    if (!_hours.contains(hour12)) hour12 = 9;
    final minutes = _minutesFor(hour12);
    if (!minutes.contains(minute)) minute = minutes.last;

    _hourIndex = _hours.indexOf(hour12);
    _minuteIndex = minutes.indexOf(minute);

    _hourCtrl = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minuteIndex);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _roundedNow() {
    final now = DateTime.now();
    final rounded = ((now.minute ~/ 15) + 1) * 15;
    return TimeOfDay(hour: (now.hour + rounded ~/ 60) % 24, minute: rounded % 60);
  }

  TimeOfDay _currentSelection() =>
      TimeOfDay(hour: _toHour24(_hours[_hourIndex]), minute: _minutes[_minuteIndex]);

  void _onHourChanged(int newHourIndex) {
    final newMinutes = _minutesFor(_hours[newHourIndex]);
    final minuteNeedsClamping = _minuteIndex >= newMinutes.length;
    final newMinuteIndex = minuteNeedsClamping ? newMinutes.length - 1 : _minuteIndex;

    setState(() {
      _hourIndex = newHourIndex;
      _minuteIndex = newMinuteIndex;
    });
    // Only the 5 PM hour shrinks the minute list (4 options -> 2), so
    // this only actually snaps the minute wheel in that one transition.
    if (minuteNeedsClamping) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _minuteCtrl.jumpToItem(newMinuteIndex);
      });
    }
  }

  void _confirm() => widget.controller.setScheduledTime(_currentSelection());

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

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
              const Expanded(
                child: Text(
                  'Every slot shown is within canteen hours',
                  style: TextStyle(fontSize: 11.5, color: CartColors.textSecondary),
                ),
              ),
              // Always enabled: the wheel can only ever land on a valid
              // 9:00 AM–5:15 PM slot by construction (see _hours/_minutesFor),
              // so there's nothing left to block Confirm on.
              TextButton(
                onPressed: _confirm,
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
              label: controller.pickupMode == PickupMode.scheduled && controller.scheduledTime != null
                  ? '🕐 ${_formatTimeOfDay(controller.scheduledTime!)}'
                  : '🕐 Schedule',
              selected: controller.pickupMode == PickupMode.scheduled,
              onTap: () => controller.setPickupMode(PickupMode.scheduled),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: '⚡ ASAP · ~${controller.asapEstimateMinutes} min',
              selected: controller.pickupMode == PickupMode.asap,
              onTap: () => controller.setPickupMode(PickupMode.asap),
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
                onChanged: _onHourChanged,
              ),
              _wheelColumn(
                scrollController: _minuteCtrl,
                itemExtent: itemExtent,
                itemCount: _minutes.length,
                labelBuilder: (i) => _minutes[i].toString().padLeft(2, '0'),
                onChanged: (i) => setState(() => _minuteIndex = i),
              ),
              // AM/PM is derived from the selected hour, not an
              // independent wheel — this just displays it, centered to
              // match the other two columns' look.
              Expanded(
                child: Center(
                  child: Text(
                    _periodLabel(_hours[_hourIndex]),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CartColors.textPrimary,
                    ),
                  ),
                ),
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
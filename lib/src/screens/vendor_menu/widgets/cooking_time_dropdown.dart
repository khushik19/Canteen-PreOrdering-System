import 'package:flutter/material.dart';

class CookingTimeDropdown extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onChanged;

  const CookingTimeDropdown({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
  });

  static const List<int> availableTimes = [5, 10, 15, 20, 25, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: availableTimes.contains(selectedMinutes) ? selectedMinutes : 15,
      dropdownColor: const Color(0xFF1E222A),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: 'Cooking / Prep Time',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: const Icon(Icons.timer_outlined, color: Color(0xFFFFB300)),
        filled: true,
        fillColor: const Color(0xFF1E222A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: availableTimes.map((mins) {
        return DropdownMenuItem<int>(
          value: mins,
          child: Row(
            children: [
              Text('$mins minutes'),
              if (mins <= 10)
                const Text(' ⚡ Fast Prep', style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}

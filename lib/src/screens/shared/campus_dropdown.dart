import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/campus_controller.dart';
import '../../core/theme/theme.dart';

// ---------------------------------------------------------------------------
// CampusDropdown — Dropdown button for picking the active college campus.
//
// Shared by Home and Menu screens.
// Accessible (min 48px touch target, keyboard accessible via Tab & Enter).
// ---------------------------------------------------------------------------

class CampusDropdown extends StatelessWidget {
  const CampusDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final campusController = context.watch<CampusController>();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: campusController.campusId,
          borderRadius: BorderRadius.circular(AppRadius.card),
          dropdownColor: AppColors.surface,
          icon: const Padding(
            padding: EdgeInsets.only(left: AppSpacing.xs),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
          items: AppConstants.campuses.map((campus) {
            return DropdownMenuItem<String>(
              value: campus.id,
              child: Text(
                campus.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newId) {
            if (newId != null) {
              context.read<CampusController>().setCampus(newId);
            }
          },
        ),
      ),
    );
  }
}

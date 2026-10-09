import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:canteen_crave/src/core/theme/theme.dart';

// ---------------------------------------------------------------------------
// AuthTextField — a styled TextFormField for auth screens.
//
// Provides consistent styling, autofill hints, keyboard types, and
// input formatters. All auth forms use this instead of raw TextFormField.
// ---------------------------------------------------------------------------

class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? prefix;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.prefix,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label above the input
        Text(label, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.xs),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          enabled: enabled,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            prefix: prefix,
            counterText: '', // hide the character counter for maxLength
          ),
        ),
      ],
    );
  }
}

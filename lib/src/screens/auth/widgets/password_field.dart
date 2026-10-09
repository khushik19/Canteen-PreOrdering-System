import 'package:flutter/material.dart';

import 'package:canteen_crave/src/core/theme/theme.dart';

// ---------------------------------------------------------------------------
// PasswordField — a TextFormField with a show/hide eye toggle.
//
// Used on: Sign In (password), Sign Up (password + confirm password).
// ---------------------------------------------------------------------------

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final void Function(String)? onFieldSubmitted;

  const PasswordField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  // Start with the password hidden.
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(widget.label, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.xs),

        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          enabled: widget.enabled,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter your password',
            // Eye icon to toggle visibility.
            suffixIcon: IconButton(
              icon: Icon(
                _obscured
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
          ),
        ),
      ],
    );
  }
}

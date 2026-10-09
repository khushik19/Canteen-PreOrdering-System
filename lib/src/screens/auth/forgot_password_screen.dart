import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:canteen_crave/src/core/theme/theme.dart';
import 'package:canteen_crave/src/core/utils/validators.dart';
import 'auth_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';

// ---------------------------------------------------------------------------
// ForgotPasswordScreen — sends a password reset email.
//
// Two states:
//   1. Form state: email field + "Send reset link" button.
//   2. Success state: confirmation message + "Back to Sign In" button.
// ---------------------------------------------------------------------------

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Tracks whether the reset email was sent successfully.
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    auth.clearError();

    final success = await auth.sendPasswordReset(
      _emailController.text.trim(),
    );

    // Only update the UI if this widget is still mounted.
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _emailSent ? _buildSuccessState() : _buildFormState(auth),
          ),
        ),
      ),
    );
  }

  /// The form with email field and submit button.
  Widget _buildFormState(AuthController auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(tagline: 'Reset your password'),
          Text(
            "Enter the email you signed up with and we'll send you a link to reset your password.",
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.l),

          // --- Email field ---
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            enabled: !auth.isLoading,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _handleReset(),
          ),
          const SizedBox(height: AppSpacing.l),

          // --- Inline error ---
          if (auth.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Text(
                auth.errorMessage!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],

          // --- Send reset link button ---
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _handleReset,
              child: auth.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send Reset Link'),
            ),
          ),
        ],
      ),
    );
  }

  /// Shown after the reset email was sent successfully.
  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),

        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        Text('Check your inbox', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.s),
        Text(
          'We sent a password reset link to\n${_emailController.text.trim()}',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Sign In'),
          ),
        ),
      ],
    );
  }
}


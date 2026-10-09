import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:canteen_crave/src/core/theme/theme.dart';
import 'package:canteen_crave/src/core/utils/validators.dart';
import 'package:canteen_crave/src/app/routes/app_routes.dart';
import 'auth_controller.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_field.dart';

// ---------------------------------------------------------------------------
// SignInScreen — email + password login.
//
// Layout:
//   • AuthHeader (logo, title, tagline)
//   • Email field
//   • Password field (with eye toggle)
//   • "Forgot password?" link (right-aligned)
//   • "Sign In" button (full-width, with spinner while loading)
//   • Inline error message (if any)
//   • "New here? Sign up" link at the bottom
//
// Responsive: on wide screens (web), the form is centered with max-width 420.
// ---------------------------------------------------------------------------

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Form key for validation.
  final _formKey = GlobalKey<FormState>();

  // Text controllers to read the field values.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Called when the user taps "Sign In" or presses the keyboard done key.
  Future<void> _handleSignIn() async {
    // Don't submit if already loading (prevents double taps).
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    // Validate the form fields.
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous error.
    auth.clearError();

    // Call the controller — it talks to the repository/Firebase.
    await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    // If successful, the router redirect handles navigation.
    // If failed, auth.errorMessage is set and the UI rebuilds.
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller so we rebuild when isLoading/errorMessage changes.
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: ConstrainedBox(
            // On web/wide screens, keep the form narrow and centered.
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Logo + title + tagline ---
                    const AuthHeader(),

                    // --- Email field ---
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      enabled: !auth.isLoading,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // --- Password field ---
                    PasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      validator: Validators.password,
                      enabled: !auth.isLoading,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _handleSignIn(),
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // --- Forgot password link (right-aligned) ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () => context.push(AppRoutes.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // --- Inline error message ---
                    if (auth.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                    ],

                    // --- Sign In button ---
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSignIn,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- "New here? Sign up" ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New here? ', style: AppTextStyles.body),
                        GestureDetector(
                          onTap: auth.isLoading
                              ? null
                              : () => context.go(AppRoutes.signup),
                          child: Text(
                            'Sign up',
                            style: AppTextStyles.bodyBold.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

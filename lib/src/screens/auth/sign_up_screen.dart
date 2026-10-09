import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:canteen_crave/src/core/theme/theme.dart';
import 'package:canteen_crave/src/core/utils/validators.dart';
import 'package:canteen_crave/src/core/constants/app_constants.dart';
import 'package:canteen_crave/src/app/routes/app_routes.dart';
import 'auth_controller.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/password_field.dart';

// ---------------------------------------------------------------------------
// SignUpScreen — create a new student account.
//
// Fields: Name, Phone (+91 prefix), Email, Password, Confirm, Campus dropdown.
// Wrapped in SingleChildScrollView so the keyboard never causes overflow.
// Responsive: max-width 420 on wide screens.
// ---------------------------------------------------------------------------

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field.
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Selected campus ID (from the dropdown).
  String? _selectedCampusId;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Called when the user taps "Create Account".
  Future<void> _handleSignUp() async {
    final auth = context.read<AuthController>();
    if (auth.isLoading) return;

    // Validate all fields including the campus dropdown.
    if (!_formKey.currentState!.validate()) return;

    auth.clearError();

    await auth.signUp(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      campusId: _selectedCampusId!,
    );
    // Router redirect handles navigation on success.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      // Back arrow in the app bar.
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Title ---
                    Text('Create your account', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sign up to start pre-ordering your meals.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- Full Name ---
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'John Doe',
                      keyboardType: TextInputType.name,
                      validator: Validators.name,
                      enabled: !auth.isLoading,
                      autofillHints: const [AutofillHints.name],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // --- Mobile Number (+91 prefix) ---
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      hintText: '9876543210',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.phone,
                      enabled: !auth.isLoading,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      // Fixed +91 prefix shown before the input.
                      prefix: Text('+91  ', style: AppTextStyles.body),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // --- Email ---
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      enabled: !auth.isLoading,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // --- Password ---
                    PasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'At least 8 characters',
                      validator: Validators.password,
                      enabled: !auth.isLoading,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // --- Confirm Password ---
                    PasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      enabled: !auth.isLoading,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // --- Campus Dropdown ---
                    Text('Campus', style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCampusId,
                      validator: Validators.campus,
                      decoration: const InputDecoration(
                        hintText: 'Select your campus',
                      ),
                      items: AppConstants.campuses.map((campus) {
                        return DropdownMenuItem(
                          value: campus.id,
                          child: Text(campus.displayName),
                        );
                      }).toList(),
                      onChanged: auth.isLoading
                          ? null
                          : (value) {
                              setState(() => _selectedCampusId = value);
                            },
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- Inline error message ---
                    if (auth.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
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

                    // --- Create Account button ---
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSignUp,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- "Already have an account? Sign in" ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                            style: AppTextStyles.body),
                        GestureDetector(
                          onTap: auth.isLoading
                              ? null
                              : () => context.go(AppRoutes.login),
                          child: Text(
                            'Sign in',
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


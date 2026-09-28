import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../vendor_dashboard/vendor_main_nav_screen.dart';
import 'vendor_register_screen.dart';

class VendorLoginScreen extends StatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  State<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted && userCredential.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VendorMainNavScreen(vendorId: userCredential.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Login failed. Please check credentials.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Quick Demo Login bypass for testing without Firebase Auth configuration
  void _loginAsDemoVendor() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const VendorMainNavScreen(vendorId: 'vendor_demo_101'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF6B00), width: 2),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 40,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Vendor Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your canteen menu, live kitchen orders & stock',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Vendor Email',
                      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF6B00)),
                      filled: true,
                      fillColor: const Color(0xFF1E222A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter email';
                      if (!val.contains('@')) return 'Invalid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF6B00)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E222A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 26),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFFF6B00).withValues(alpha: 0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'Sign In to Canteen',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _loginAsDemoVendor,
                    icon: const Icon(Icons.flash_on, color: Color(0xFFFFB300), size: 18),
                    label: const Text('Fast Demo Mode (Instant Access)', style: TextStyle(color: Color(0xFFFFB300))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFFFFB300).withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New Canteen Vendor? ',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const VendorRegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register Canteen',
                          style: TextStyle(
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

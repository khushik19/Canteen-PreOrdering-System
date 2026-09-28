import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/vendor_model.dart';
import '../../repositories/vendor_repository.dart';
import '../vendor_dashboard/vendor_main_nav_screen.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _canteenNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCampus = 'Main Campus';
  final List<String> _campuses = ['Main Campus', 'North Campus', 'South Campus', 'Engineering Block'];

  bool _isLoading = false;
  final _vendorRepository = VendorRepository();

  @override
  void dispose() {
    _canteenNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final vendorId = credential.user!.uid;

      final vendor = VendorModel(
        id: vendorId,
        canteenName: _canteenNameController.text.trim(),
        campusId: _selectedCampus,
        ownerName: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isOpen: true,
        createdAt: DateTime.now(),
      );

      await _vendorRepository.saveVendorProfile(vendor);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => VendorMainNavScreen(vendorId: vendorId),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Registration failed'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register Canteen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Set up your Canteen Outlet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join Canteen Crave and start receiving digital pre-orders from students.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  controller: _canteenNameController,
                  label: 'Canteen / Outlet Name',
                  icon: Icons.restaurant,
                  hint: 'e.g. Central Cafeteria, Nescafe Corner',
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _ownerNameController,
                  label: 'Manager / Owner Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCampus,
                  dropdownColor: const Color(0xFF1E222A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Campus Location',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFFF6B00)),
                    filled: true,
                    fillColor: const Color(0xFF1E222A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _campuses.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCampus = val);
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _passwordController,
                  label: 'Create Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Complete Canteen Setup',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6B00)),
        filled: true,
        fillColor: const Color(0xFF1E222A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator ??
          (val) {
            if (val == null || val.trim().isEmpty) return 'This field is required';
            return null;
          },
    );
  }
}

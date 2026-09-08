// lib/pages/user_register.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../controllers/user_profile_controller.dart';
import 'profile_page.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final _formKey = GlobalKey<FormState>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<UserProfileController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Save your details and order medicines faster next time.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                label: 'First name',
                                controller: firstNameCtrl,
                                icon: Icons.person_outline,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _field(
                                label: 'Last name',
                                controller: lastNameCtrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _field(
                          label: 'Email address',
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          label: 'Phone number',
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          label: 'Delivery address',
                          controller: addressCtrl,
                          keyboardType: TextInputType.streetAddress,
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          label: 'Password',
                          controller: passwordCtrl,
                          obscureText: true,
                          icon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: loading
                                ? null
                                : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              setState(() => loading = true);
                              try {
                                await profile.register(
                                  firstName: firstNameCtrl.text.trim(),
                                  lastName: lastNameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  address: addressCtrl.text.trim(),
                                  password: passwordCtrl.text.trim(),
                                );
                                Get.offAll(() => ProfilePage());
                              } catch (e) {
                                Get.snackbar(
                                  'Registration failed',
                                  e.toString(),
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } finally {
                                setState(() => loading = false);
                              }
                            },
                            child: loading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Create account',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }
}

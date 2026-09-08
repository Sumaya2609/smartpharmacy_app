// lib/pages/user_login.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';
import '../colors.dart';
import 'user_register.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  final UserProfileController profile = Get.find<UserProfileController>();

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Login to continue ordering your medicines.',
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
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: passwordCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // hook forgot password later
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: loading ? null : _login,
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
                              'Login',
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
                      "Don't have an account?",
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const UserRegister()),
                      child: const Text(
                        'Create one',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await profile.login(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => loading = false);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../routes.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Smart Pharmacy',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fast, safe medicines at your doorstep.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/medicine.png',
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Admin') {
                    Get.toNamed(AppRoutes.adminLogin);
                  } else {
                    Get.toNamed('/user-home');
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'Admin',
                    child: Text('Admin'),
                  ),
                  PopupMenuItem(
                    value: 'User',
                    child: Text('User'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

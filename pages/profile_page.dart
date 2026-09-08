// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';
import '../colors.dart';
import 'user_register.dart';
import 'user_login.dart';
import 'view_profile_page.dart';
import 'user_orders_page.dart';
import 'user_delivery_page.dart';
import 'notifications_page.dart'; // <-- you will create this

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final UserProfileController profile = Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = profile.currentUser.value;

      if (user == null) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to continue',
                    style: TextStyle(color: AppColors.subtitle),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const UserLoginPage()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Get.to(() => const UserRegister()),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.title),
            onPressed: () => Get.back(),
          ),
          title: const Text('Profile'),
          elevation: 0,
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.title,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(user.fullName, user.email),
            const SizedBox(height: 20),
            _menuTile(
              icon: Icons.person,
              title: 'My Profile',
              onTap: () => Get.to(() => const ViewProfilePage()),
            ),
            _menuTile(
              icon: Icons.receipt_long,
              title: 'My Orders',
              onTap: () => Get.to(() => const UserOrdersPage()),
            ),
            _menuTile(
              icon: Icons.local_shipping,
              title: 'Delivery Status',
              onTap: () => Get.to(() => const UserDeliveryPage()),
            ),
            // // Notifications tile with red dot
            // Obx(() {
            //   final unread = profile.unreadNotifications.value;
            //   return _menuTile(
            //     icon: Icons.notifications,
            //     title: 'Notifications',
            //     onTap: () => Get.to(() => const NotificationsPage()),
            //     trailing: unread > 0
            //         ? Container(
            //       width: 10,
            //       height: 10,
            //       decoration: const BoxDecoration(
            //         color: Colors.red,
            //         shape: BoxShape.circle,
            //       ),
            //     )
            //         : const SizedBox.shrink(),
            //   );
            // }),
            _menuTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => profile.logout(),
              danger: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _headerCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primarySoft,
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(color: AppColors.subtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: danger ? AppColors.danger : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

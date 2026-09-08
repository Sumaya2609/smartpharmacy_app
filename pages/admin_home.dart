// lib/pages/admin_home.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../colors.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../routes.dart';

import 'admin_sales_report_page.dart';
import 'stock_management_page.dart';
import 'admin_orders_page.dart';
import 'admin_payments_page.dart';
import 'admin_delivery_page.dart';
import 'admin_product_list_page.dart';
import 'admin_categories_page.dart';
import 'admin_users_page.dart';

final List<Map<String, dynamic>> sidebarSections = [
  {
    'header': 'Management',
    'items': [
      {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
      {'title': 'Users', 'icon': Icons.people_alt_outlined},
      {'title': 'Orders', 'icon': Icons.shopping_bag_outlined},
      {'title': 'Payments', 'icon': Icons.payment},
      {'title': 'Deliveries', 'icon': Icons.local_shipping_outlined},
    ],
  },
  {
    'header': 'Products',
    'items': [
      {'title': 'Product List', 'icon': Icons.list_alt},
      {'title': 'Categories', 'icon': Icons.category_outlined},
      // optional: stock page
      // {'title': 'Stock', 'icon': Icons.inventory_2_outlined},
    ],
  },
  {
    'header': 'Reports',
    'items': [
      {'title': 'Sales Reports', 'icon': Icons.bar_chart},
    ],
  },
];

class AdminHome extends StatelessWidget {
  AdminHome({super.key});

  final AdminDashboardController controller =
  Get.put(AdminDashboardController());

  int _pageIndexFor(String title) {
    switch (title) {
      case 'Dashboard':
        return 0;
      case 'Users':
        return 1;
      case 'Orders':
        return 2;
      case 'Payments':
        return 3;
      case 'Deliveries':
        return 4;
      case 'Product List':
        return 5;
      case 'Categories':
        return 6;
      case 'Sales Reports':
        return 7;
    // case 'Stock':
    //   return 8;
      default:
        return 0;
    }
  }

  Widget _sidebarItem({
    required String title,
    required IconData icon,
  }) {
    final index = _pageIndexFor(title);

    return Obx(() {
      final isOpen = controller.isSidebarOpen.value;
      final isSelected = controller.selectedIndex.value == index;

      return InkWell(
        onTap: () {
          controller.selectedIndex.value = index;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft.withOpacity(0.6) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (isOpen) const SizedBox(width: 10),
              if (isOpen)
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPage() {
    return Obx(() {
      switch (controller.selectedIndex.value) {
        case 0:
          return _dashboardPage();
        case 1:
          return const AdminUsersPage();
        case 2:
          return const AdminOrdersPage();
        case 3:
          return const AdminPaymentsPage();
        case 4:
          return const AdminDeliveryPage();
        case 5:
          return AdminProductListPage();
        case 6:
          return AdminCategoriesPage();
        case 7:
          return const AdminSalesReportPage();
      // case 8:
      //   return const StockManagementPage();
        default:
          return _dashboardPage();
      }
    });
  }

  Widget _dashboardPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // responsive width for cards
        final double maxWidth = constraints.maxWidth;
        double cardWidth = 220;
        if (maxWidth < 400) {
          cardWidth = maxWidth - 40;
        } else if (maxWidth < 800) {
          cardWidth = (maxWidth - 40) / 2;
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.bg,
            foregroundColor: AppColors.title,
            title: const Text('Admin Dashboard'),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  Obx(
                        () => SizedBox(
                      width: cardWidth,
                      child: _dashboardCard(
                        title: 'Total Users',
                        value: controller.totalUsers.value.toString(),
                        icon: Icons.people_alt_outlined,
                      ),
                    ),
                  ),
                  Obx(
                        () => SizedBox(
                      width: cardWidth,
                      child: _dashboardCard(
                        title: 'Total Orders',
                        value: controller.totalOrders.value.toString(),
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                  ),
                  Obx(
                        () => SizedBox(
                      width: cardWidth,
                      child: _dashboardCard(
                        title: 'Medicines',
                        value: controller.medicines.value.toString(),
                        icon: Icons.medication_outlined,
                      ),
                    ),
                  ),
                  Obx(
                        () => SizedBox(
                      width: cardWidth,
                      child: _dashboardCard(
                        title: 'Pending Delivery',
                        value: controller.pendingDeliveries.value.toString(),
                        icon: Icons.local_shipping_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Obx(() {
      final isOpen = controller.isSidebarOpen.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isOpen ? 230 : 70,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      isOpen ? Icons.chevron_left : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: controller.toggleSidebar,
                  ),
                ),
              ),
              if (isOpen)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Smart Pharmacy\nAdmin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sidebarSections.map((section) {
                      final String header = section['header'];
                      final List items = section['items'];
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  header,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ...items.map<Widget>((item) {
                              return _sidebarItem(
                                title: item['title'],
                                icon: item['icon'],
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (Get.isRegistered<UserProfileController>()) {
                      final profile = Get.find<UserProfileController>();
                      profile.currentUser.value = null;
                    }
                    Get.offAllNamed(AppRoutes.intro);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Drawer _buildMobileDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text(
                'Smart Pharmacy Admin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: sidebarSections.expand((section) {
                  final String header = section['header'];
                  final List items = section['items'];
                  return [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        header,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    ...items.map<Widget>((item) {
                      final title = item['title'] as String;
                      final icon = item['icon'] as IconData;
                      final index = _pageIndexFor(title);
                      return Obx(
                            () => ListTile(
                          leading: Icon(icon),
                          title: Text(title),
                          selected: controller.selectedIndex.value == index,
                          onTap: () {
                            controller.selectedIndex.value = index;
                            Get.back();
                          },
                        ),
                      );
                    }).toList(),
                  ];
                }).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (Get.isRegistered<UserProfileController>()) {
                  final profile = Get.find<UserProfileController>();
                  profile.currentUser.value = null;
                }
                Get.offAllNamed(AppRoutes.intro);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          // desktop / large tablet: sidebar + content in Row
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: _buildPage(),
                ),
              ],
            ),
          );
        } else {
          // mobile / small tablet: use Drawer navigation, no horizontal overflow
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.bg,
              foregroundColor: AppColors.title,
              title: const Text('Smart Pharmacy Admin'),
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
            drawer: _buildMobileDrawer(),
            body: _buildPage(),
          );
        }
      },
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

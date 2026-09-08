// lib/pages/user_home.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../controllers/firestore_stock_controller.dart';
import '../controllers/cart_controller.dart';
import 'category_medicine_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'medicine_details_page.dart';
import 'search_page.dart';

class UserHome extends StatelessWidget {
  UserHome({super.key});

  final FirestoreStockController stock = Get.find<FirestoreStockController>();
  final CartController cart = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroCard(),
              const SizedBox(height: 16),
              _searchField(context),
              const SizedBox(height: 16),
              _offersRow(),
              const SizedBox(height: 24),
              _categoriesSection(),
              const SizedBox(height: 24),
              _featuredMedicinesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // bottom nav
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 2) {
          Get.to(() => CartPage());
        } else if (i == 3) {
          Get.to(() => ProfilePage());
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  // hero card
  // hero card
  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Need medicines today?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Order genuine medicine and health products\nwith fast home delivery.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_pharmacy_outlined,
              size: 34,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // search field → pushes to SearchPage after a few characters
  Widget _searchField(BuildContext context) {
    return TextField(
      onChanged: (v) {
        stock.searchQuery.value = v;
        if (v.length >= 2) {
          Get.to(() => const SearchPage());
        }
      },
      decoration: InputDecoration(
        hintText: 'Search medicine by name or brand',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // offers
  Widget _offersRow() {
    final offers = [
      'assets/offers/offer1.png',
      'assets/offers/offer2.png',
      'assets/offers/offer3.png',
    ];
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              offers[i],
              width: 220,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  // categories (rounded chips, no image)
  Widget _categoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (stock.categories.isEmpty) {
            return const Text('No categories');
          }
          return Wrap(
            spacing: 10,
            runSpacing: 8,
            children: stock.categories
                .map(
                  (cat) => GestureDetector(
                onTap: () =>
                    Get.to(() => CategoryMedicinePage(category: cat)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          );
        }),
      ],
    );
  }

  // featured / popular medicines (with constrained image size + stock check)
  Widget _featuredMedicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular medicines',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final meds = stock.filteredMedicines.isEmpty &&
              stock.searchQuery.isEmpty
              ? stock.medicines
              : stock.filteredMedicines;

          if (stock.searchQuery.isNotEmpty && meds.isEmpty) {
            return const Text(
              'No medicines found for this search.',
              style: TextStyle(color: Colors.red),
            );
          }

          if (meds.isEmpty) {
            return const Text('No medicines available');
          }

          final rand = Random();
          final list = meds.toList()..shuffle(rand);
          final featured = list.take(6).toList();

          return Column(
            children: featured.map((m) {
              final int stockQty = m.stock ?? 0;
              final bool isOut = stockQty <= 0;

              return GestureDetector(
                onTap: () => Get.to(() => MedicineDetailsPage(medicine: m)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.asset(
                            m.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${m.brand} • ${m.strength}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '৳${m.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isOut)
                              const Text(
                                'Out of stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isOut ? Colors.grey : AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: isOut
                            ? () {
                          Get.snackbar(
                            'Out of stock',
                            'This medicine is currently unavailable.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                            : () {
                          cart.addToCart(m);
                          Get.snackbar(
                            'Added to cart',
                            m.name,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Text(isOut ? 'Out of stock' : 'Add'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

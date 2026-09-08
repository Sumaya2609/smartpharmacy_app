import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medicine_model.dart';
import '../controllers/cart_controller.dart';
import '../colors.dart';
import '../routes.dart';

class MedicineDetailsPage extends StatelessWidget {
  final Medicine medicine;
  MedicineDetailsPage({super.key, required this.medicine});

  final CartController cart = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    final int stockQty = medicine.stock;
    final bool isOut = stockQty <= 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _image(),
                    const SizedBox(height: 18),
                    _titleSection(stockQty),
                    const SizedBox(height: 16),
                    _pillRow(stockQty, isOut),
                    const SizedBox(height: 18),
                    if (medicine.description.isNotEmpty)
                      _infoCard('Description', medicine.description),
                    _infoCard('Ingredients', medicine.ingredients),
                    _infoCard('Side effects', medicine.sideEffects),
                    const SizedBox(height: 80),
                    if (isOut) _notifyWhenRestockedButton(),
                  ],
                ),
              ),
            ),
            _bottomBar(isOut),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _circle(Icons.arrow_back, () => Get.back()),
          // const Spacer(),
          // _circle(Icons.favorite_border, () {
          //   // TODO: handle wishlist if needed
          // }),
          const SizedBox(width: 10),
          _circle(
            Icons.shopping_cart_outlined,
                () {
              Get.toNamed(AppRoutes.cart);
            },
          ),
        ],
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.title),
      ),
    );
  }

  Widget _image() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            medicine.image,
            height: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _titleSection(int stockQty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          medicine.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${medicine.brand} • ${medicine.strength}',
          style: const TextStyle(
            color: AppColors.subtitle,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _pillRow(int stockQty, bool isOut) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.currency_bitcoin_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '৳${medicine.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOut ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isOut ? Icons.error_outline : Icons.inventory_2_outlined,
                size: 16,
                color: isOut ? Colors.red.shade700 : Colors.green.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                isOut ? 'Out of stock' : 'Stock: $stockQty',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOut ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.star, color: AppColors.warning, size: 18),
        const SizedBox(width: 4),
        Text(
          medicine.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? 'No information available.' : value,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifyWhenRestockedButton() {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: user == null
              ? null
              : () async {
            final db = FirebaseFirestore.instance;
            await db
                .collection('users')
                .doc(user.uid)
                .collection('restock_subscriptions')
                .doc(medicine.id)
                .set({
              'medicineId': medicine.id,
              'createdAt': FieldValue.serverTimestamp(),
            });

            Get.snackbar(
              'Subscribed',
              'You will be notified when this medicine is restocked.',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Notify when restocked'),
        ),
      ),
    );
  }

  Widget _bottomBar(bool isOut) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.card,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isOut
                  ? () {
                Get.snackbar(
                  'Out of stock',
                  'This medicine is currently unavailable.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
                  : () {
                cart.addToCart(medicine);
                Get.snackbar(
                  'Added to cart',
                  medicine.name,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isOut ? Colors.grey : AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(isOut ? 'Out of stock' : 'Add to cart'),
            ),
          ),
        ],
      ),
    );
  }
}

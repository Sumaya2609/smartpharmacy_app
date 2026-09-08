// lib/pages/cart_page.dart - Complete stock validation fix
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../colors.dart';
import 'user_login.dart';
import 'payment_page.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final CartController cart = Get.find<CartController>();
  final UserProfileController profile = Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Obx(() {
          if (cart.cartItems.isEmpty) {
            return _emptyState();
          }
          return Column(
            children: [
              _topBar(),
              Expanded(child: _cartList()),
              _bottomCheckout(),
            ],
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_bag_outlined,
              size: 64, color: AppColors.subtitle),
          SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.title,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add some medicines to get started.',
            style: TextStyle(color: AppColors.subtitle, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 6),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'My cart (${cart.cartItems.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.title,
            ),
          ),
          const Spacer(),
          // ✅ FIXED: Better stock warning
          Obx(() => cart.hasOutOfStockItems
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                const Text(
                  'Stock Issue',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _cartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      itemCount: cart.cartItems.length,
      itemBuilder: (_, i) {
        final item = cart.cartItems[i];
        final bool exceedsStock = item.quantity > item.medicine.stock;
        final bool outOfStock = item.medicine.stock <= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: outOfStock
                ? Colors.red.shade50
                : exceedsStock
                ? Colors.orange.shade50
                : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: outOfStock
                ? Border.all(color: Colors.red.shade300, width: 2)
                : exceedsStock
                ? Border.all(color: Colors.orange.shade300, width: 2)
                : null,
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 6),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.medicine.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.primarySoft,
                    child: Icon(Icons.medication, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.medicine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: outOfStock
                            ? Colors.red.shade700
                            : AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.medicine.brand} • ${item.medicine.strength}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '৳${item.medicine.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'x${item.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: exceedsStock
                                ? Colors.orange.shade700
                                : AppColors.title,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '৳${item.total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: outOfStock
                                ? Colors.red.shade600
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (outOfStock) ...[
                      const SizedBox(height: 6),
                      _stockBadge('Out of Stock', Colors.red),
                    ] else if (exceedsStock) ...[
                      const SizedBox(height: 6),
                      _stockBadge(
                          'Only ${item.medicine.stock} left',
                          Colors.orange
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ✅ FIXED: Proper quantity controls
              if (!outOfStock) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _qtyBtn(
                      Icons.add,
                          () => cart.changeQuantity(item, 1),
                      exceedsStock ? Colors.grey : null,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: exceedsStock
                              ? Colors.orange.shade700
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _qtyBtn(
                      Icons.remove,
                          () => cart.changeQuantity(item, -1),
                      null,
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.block,
                    color: Colors.red.shade500,
                    size: 28,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, Color? disabledColor) {
    return InkWell(
      onTap: disabledColor == null ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: disabledColor ?? AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: disabledColor ?? AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _stockBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _bottomCheckout() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Row
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.title,
                ),
              ),
              const Spacer(),
              Text(
                '৳${cart.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cart.hasOutOfStockItems
                      ? Colors.red.shade600
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Items count with warning
          Row(
            children: [
              Text(
                '${cart.cartItems.length} item${cart.cartItems.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subtitle,
                ),
              ),
              if (cart.hasOutOfStockItems) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        'Fix stock issues',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          // ✅ FIXED: Complete checkout validation
          Obx(() => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: cart.canCheckout && profile.currentUser.value != null
                  ? () {
                Get.to(() => const PaymentPage());
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cart.canCheckout
                    ? AppColors.primary
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                elevation: cart.canCheckout ? 8 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: cart.hasOutOfStockItems
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Fix cart issues first',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              )
                  : profile.currentUser.value == null
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login),
                  const SizedBox(width: 8),
                  Text(
                    'Login to Checkout',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment),
                  const SizedBox(width: 8),
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

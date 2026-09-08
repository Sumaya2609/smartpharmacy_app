// lib/pages/payment_page.dart - FULL VERSION WITH CART FIX
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_pharmacy_app/pages/sslcommerz_payment_page.dart';

import '../controllers/user_profile_controller.dart';
import '../controllers/cart_controller.dart';
import '../colors.dart';
import '../services/sslcommerz_service.dart';
import 'user_orders_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _paymentMethod = 'Cash on delivery';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CART SUMMARY (shows real items/total)
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 16),

                  //  PAYMENT METHODS
                  const Text(
                    'Payment method:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    dense: true,
                    title: const Text('Cash on delivery'),
                    subtitle: const Text('Pay when medicine arrives'),
                    value: 'Cash on delivery',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  RadioListTile<String>(
                    dense: true,
                    title: const Text('Online payment'),
                    subtitle: const Text('bKash/Nagad/Cards (Secure)'),
                    value: 'Online payment',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),

                  const Divider(),

                  //  REAL CART TOTAL
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total (incl. tax):',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.subtitle,
                          ),
                        ),
                        Text(
                          '৳${cart.total.toStringAsFixed(2)}',  // ✅ 2 decimals
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CART ITEMS PREVIEW
                  if (cart.cartItems.isNotEmpty)
                    ...cart.cartItems.take(2).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.medicine.name} ×${item.quantity}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '৳${(item.medicine.price * item.quantity).toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),

                  if (cart.cartItems.length > 2)
                    Text(
                      '+${cart.cartItems.length - 2} more items',
                      style: TextStyle(fontSize: 12, color: AppColors.subtitle),
                    ),
                ],
              ),
            ),

            const Spacer(),

            // PLACE ORDER BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 4,
                ),
                onPressed: loading || cart.total <= 0 || cart.cartItems.isEmpty
                    ? null
                    : _placeOrder,
                child: loading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
                    : cart.total <= 0
                    ? const Text(
                  'Add Items to Cart',
                  style: TextStyle(fontWeight: FontWeight.w600),
                )
                    : Text(
                  'Place Order ৳${cart.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    try {
      //  CART DEBUG
      final cart = Get.find<CartController>();
      debugPrint("🛒 CART DEBUG:");
      debugPrint("Items: ${cart.cartItems.length}");
      debugPrint("Total: ৳${cart.total}");
      for (var item in cart.cartItems) {
        debugPrint("📦 ${item.medicine.name}: ${item.quantity} × ৳${item.medicine.price}");
      }

      if (cart.cartItems.isEmpty || cart.total <= 0) {
        Get.snackbar(
          'Empty Cart',
          'Please add medicines before checkout!',
          backgroundColor: Colors.red,
        );
        return;
      }

      setState(() => loading = true);

      final profile = Get.find<UserProfileController>();
      final user = profile.currentUser.value!;
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;

      // Create order
      final orderRef = db.collection('orders').doc();

      await orderRef.set({
        'userId': uid,
        'userName': user.fullName,
        'userEmail': user.email,
        'phone': user.phone,
        'address': user.address,
        'items': cart.cartItems.map((ci) => {
          'medicineId': ci.medicine.id,
          'name': ci.medicine.name,
          'qty': ci.quantity,
          'price': ci.medicine.price,
          'total': ci.total,
        }).toList(),
        'subtotal': cart.total,
        'total': cart.total,
        'status': 'Pending Payment',
        'paymentStatus': 'Pending',
        'paymentMethod': _paymentMethod,
        'isOnlinePaid': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("📝 Order created: ${orderRef.id}");

      if (_paymentMethod == 'Cash on delivery') {
        await orderRef.update({'status': 'Order confirmed'});
        cart.clear();
        setState(() => loading = false);
        Get.off(() => const UserOrdersPage());
        Get.snackbar('Order Placed!', 'COD order confirmed!');
        return;
      }

      // Online payment
      setState(() => loading = false);
      Get.to(() => SSLCommerzPaymentPage(
        orderRef: orderRef,
        totalAmount: cart.total,  //  REAL cart total passed
        customer: {
          'name': user.fullName,
          'email': user.email,
          'phone': user.phone,
          'address': user.address,
          'city': 'Dhaka',
          'country': 'Bangladesh',
          'postcode': '1200',
          'state': 'Dhaka',
        },
      ));

    } catch (e) {
      debugPrint("❌ Order error: $e");
      setState(() => loading = false);
      Get.snackbar('Error', 'Failed to create order: $e');
    }
  }
}

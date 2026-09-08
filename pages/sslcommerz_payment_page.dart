import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';
import '../services/sslcommerz_service.dart';
import 'user_orders_page.dart';

class SSLCommerzPaymentPage extends StatelessWidget {
  final DocumentReference orderRef;
  final double totalAmount;
  final Map<String, String> customer;

  const SSLCommerzPaymentPage({
    super.key,
    required this.orderRef,
    required this.totalAmount,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ DEBUG: Log real amount
    debugPrint("💳 PAYMENT PAGE - Amount: ৳$totalAmount");

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Pay ৳${totalAmount.toStringAsFixed(2)}'),  // ✅ 2 decimals
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ PROMINENT AMOUNT DISPLAY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.payment, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Secure Payment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'bKash • Nagad • Cards • Rocket',
                    style: TextStyle(fontSize: 14, color: AppColors.subtitle),
                  ),
                  const SizedBox(height: 24),
                  // ✅ MASSIVE REAL AMOUNT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '৳',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        totalAmount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // ✅ Pay Button with REAL AMOUNT
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.payment, size: 24),
                label: Text(
                  'Pay ৳${totalAmount.toStringAsFixed(0)} Now',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                onPressed: totalAmount > 0 ? () => _startPayment(context) : null,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _startPayment(BuildContext context) {
    debugPrint("🚀 SSLCommerz starting - Amount: ৳$totalAmount");

    SSLCommerzService.initiatePayment(
      context: context,
      amount: totalAmount,  // ✅ Passes REAL cart total
      customer: customer,
      onResult: (PaymentResult result) {
        debugPrint("💰 Result: ${result.isSuccess ? 'SUCCESS' : 'FAILED'} - ${result.message}");

        if (result.isSuccess) {
          orderRef.update({
            'paymentStatus': 'Paid',
            'isOnlinePaid': true,
            'tranId': result.tranId ?? 'manual',
            'updatedAt': FieldValue.serverTimestamp(),
          }).then((_) {
            Get.offAll(() => const UserOrdersPage());
            Get.dialog(
              AlertDialog(
                title: const Text('✅ Payment Success!'),
                content: Text('Order confirmed\nTran ID: ${result.tranId}'),
                actions: [
                  TextButton(
                    onPressed: () => Get.offAll(() => const UserOrdersPage()),
                    child: const Text('View Orders'),
                  ),
                ],
              ),
            );
          });
        } else {
          orderRef.update({
            'paymentStatus': 'Failed',
            'failedReason': result.failedReason ?? 'Unknown',
          }).then((_) {
            Get.back();
            Get.snackbar(
              'Payment Failed',
              result.message,
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            );
          });
        }
      },
    );
  }
}

// lib/pages/admin_orders_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../colors.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Orders'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No orders'));
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final o = docs[i];
              final userId = o['userId'] as String;
              final total = (o['total'] ?? 0).toDouble();
              final status = o['status'] ?? 'Pending';
              final paymentStatus = o['paymentStatus'] ?? 'Pending';
              final paymentMethod =
                  o['paymentMethod'] ?? 'Cash on delivery';
              final ts = o['createdAt'] as Timestamp?;
              final date = ts != null ? ts.toDate() : DateTime.now();

              Color statusColor = AppColors.warning;
              if (status == 'Delivered') statusColor = AppColors.success;
              if (status == 'Cancelled') statusColor = AppColors.danger;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (_, userSnap) {
                  String userName = 'Unknown user';
                  String userEmail = '';
                  if (userSnap.hasData && userSnap.data!.exists) {
                    final data =
                    userSnap.data!.data() as Map<String, dynamic>;
                    userName =
                        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                            .trim();
                    userEmail = data['email'] ?? '';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: order id + total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${o.id.substring(0, 6)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.title,
                              ),
                            ),
                            Text(
                              '৳${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.title,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Placed: ${date.toLocal()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Order: $status',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Payment: $paymentStatus ($paymentMethod)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// lib/pages/user_orders_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../colors.dart';
import 'order_receipt_page.dart';

class UserOrdersPage extends StatelessWidget {
  const UserOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Please login to see your orders.'),
        ),
      );
    }

    // Filter: only this user's orders, newest first
    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}'),
            );
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final o = docs[i];
              final data = o.data() as Map<String, dynamic>;

              final total = (data['total'] ?? 0).toDouble();
              final status = data['status'] ?? 'Pending';
              final paymentStatus = data['paymentStatus'] ?? 'Pending';
              final paymentMethod =
                  data['paymentMethod'] ?? 'Cash on delivery';
              final ts = data['createdAt'] as Timestamp?;
              final date = ts != null ? ts.toDate().toLocal() : DateTime.now();

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderReceiptPage(orderDoc: o),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.bg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
                          Expanded(
                            child: Text(
                              'Order #${o.id.substring(0, 6)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '৳${total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Placed: ${date.toLocal()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Use Wrap instead of Row so chips can go to next line
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            label: Text(
                              'Order: $status',
                              overflow: TextOverflow.ellipsis,
                            ),
                            backgroundColor: Colors.blue.shade50,
                          ),
                          Chip(
                            label: SizedBox(
                              // Constrain label so it can wrap/ellipsis inside chip
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                'Payment: $paymentStatus ($paymentMethod)',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            backgroundColor: Colors.green.shade50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

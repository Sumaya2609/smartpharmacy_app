// lib/pages/user_delivery_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../colors.dart';

class UserDeliveryPage extends StatelessWidget {
  const UserDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Delivery status'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Please login to see delivery status.'),
        ),
      );
    }

    print('DELIVERY PAGE for uid=${user.uid}');

    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)         // matches userId field
        .orderBy('createdAt', descending: true)       // uses createdAt timestamp
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery status'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          print(
            'DELIVERY state=${snap.connectionState} '
                'hasError=${snap.hasError} '
                'hasData=${snap.hasData} '
                'docs=${snap.data?.docs.length}',
          );

          if (snap.hasError) {
            print('DELIVERY error: ${snap.error}');
            return Center(
              child: Text('Error: ${snap.error}'),
            );
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No deliveries yet'));
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final o = docs[i];
              final data = o.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'Pending';
              final ts = data['createdAt'] as Timestamp?;
              final date = ts != null ? ts.toDate().toLocal() : DateTime.now();

              print('DELIVERY docId=${o.id} status=$status');

              Color badgeColor;
              if (status == 'Delivered') {
                badgeColor = Colors.green.shade100;
              } else if (status == 'Prepared for Delivery' ||
                  status == 'Packed') {
                badgeColor = Colors.orange.shade100;
              } else {
                badgeColor = Colors.red.shade100;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${o.id.substring(0, 6)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Placed: $date',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

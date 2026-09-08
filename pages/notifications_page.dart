// lib/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Please login to see notifications.'),
        ),
      );
    }

    final db = FirebaseFirestore.instance;
    final notifRef = db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notifRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final docs = snap.data!.docs;

          // mark all as read once data is loaded
          for (final d in docs) {
            final data = d.data() as Map<String, dynamic>;
            if (data['read'] != true) {
              d.reference.update({'read': true});
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final n = docs[i];
              final data = n.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              final ts = data['createdAt'] as Timestamp?;
              final date =
              ts != null ? ts.toDate().toLocal() : DateTime.now();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
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

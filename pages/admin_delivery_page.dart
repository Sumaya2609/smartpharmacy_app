// lib/pages/admin_delivery_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../colors.dart';

class AdminDeliveryPage extends StatelessWidget {
  const AdminDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Management'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData) {
            return const Center(child: Text('No active deliveries'));
          }

          final docs = snap.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['status'] != 'Delivered';
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No active deliveries'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final o = docs[i];
              final data = o.data() as Map<String, dynamic>;
              final total = (data['total'] ?? 0).toDouble();
              final status = data['status'] ?? 'Order confirmed';
              final paymentStatus = data['paymentStatus'] ?? 'Pending';
              final paymentMethod =
                  data['paymentMethod'] ?? 'Cash on delivery';

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    'Order #${o.id.substring(0, 6)} • ৳${total.toStringAsFixed(0)}',
                  ),
                  subtitle: Text(
                    'Status: $status\nPayment: $paymentStatus',
                  ),
                  trailing: _statusMenu(
                    context: _,
                    orderRef: ordersRef.doc(o.id),
                    currentStatus: status,
                    currentPaymentStatus: paymentStatus,
                    paymentMethod: paymentMethod,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusMenu({
    required BuildContext context,
    required DocumentReference orderRef,
    required String currentStatus,
    required String currentPaymentStatus,
    required String paymentMethod,
  }) {
    final all = [
      'Order confirmed',
      'Pending',
      'Packed',
      'Prepared for Delivery',
      'Delivered',
    ];

    int idx = all.indexOf(currentStatus);
    if (idx < 0) idx = 0;

    final allowed = all.sublist(idx);

    if (currentStatus == 'Delivered') {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      onSelected: (v) async {
        if (v == currentStatus) return;

        final updateData = <String, dynamic>{
          'status': v,
        };

        // Payment auto-update logic
        if (paymentMethod == 'Online payment') {
          if (currentPaymentStatus != 'Payment done') {
            updateData['paymentStatus'] = 'Payment done';
          }
        } else if (paymentMethod == 'Cash on delivery') {
          if (v == 'Delivered' && currentPaymentStatus != 'Payment done') {
            updateData['paymentStatus'] = 'Payment done';
          }
        }

        try {
          if (v == 'Delivered') {
            await _updateStockOnDelivered(orderRef, updateData);
          } else {
            await orderRef.update(updateData);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status updated to $v')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: $e')),
          );
        }
      },
      itemBuilder: (_) => allowed
          .map(
            (s) => PopupMenuItem<String>(
          value: s,
          child: Text(s),
        ),
      )
          .toList(),
      child: const Icon(Icons.edit),
    );
  }

  Future<void> _updateStockOnDelivered(
      DocumentReference orderRef,
      Map<String, dynamic> updateData,
      ) async {
    final db = orderRef.firestore;

    try {
      await db.runTransaction((transaction) async {
        final orderSnap = await transaction.get(orderRef);
        if (!orderSnap.exists) {
          debugPrint('TX-DEBUG: order not found ${orderRef.id}');
          return;
        }

        final data = orderSnap.data() as Map<String, dynamic>? ?? {};
        final List items = data['items'] as List? ?? [];
        debugPrint('TX-DEBUG: items length = ${items.length}');

        for (final it in items) {
          debugPrint('TX-DEBUG item: $it');

          final medId = it['medicineId'];
          final qtyRaw = it['qty'];

          if (medId == null || (medId is String && medId.isEmpty)) {
            throw Exception('medicineId missing in item: $it');
          }
          if (qtyRaw == null) {
            throw Exception('qty missing in item: $it');
          }

          final int qty = (qtyRaw is int)
              ? qtyRaw
              : int.tryParse(qtyRaw.toString()) ?? 0;

          final medRef = db.collection('medicines').doc(medId.toString());
          final medSnap = await transaction.get(medRef);
          if (!medSnap.exists) {
            throw Exception('Medicine not found: $medId');
          }

          final medData = medSnap.data() as Map<String, dynamic>? ?? {};
          final currentStockRaw = medData['stock'];
          final int currentStock = (currentStockRaw is int)
              ? currentStockRaw
              : int.tryParse(currentStockRaw.toString()) ?? 0;

          final int newStock =
          (currentStock - qty).clamp(0, 1000000000);
          debugPrint(
              'TX-DEBUG: med=$medId stock $currentStock -> $newStock (qty=$qty)');

          transaction.update(medRef, {'stock': newStock});
        }

        debugPrint('TX-DEBUG: updating order ${orderRef.id} with $updateData');
        transaction.update(orderRef, updateData);
      });
    } catch (e, st) {
      debugPrint('updateStockOnDelivered error INNER: $e');
      debugPrint('STACK: $st');
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../colors.dart';

class AdminPaymentsPage extends StatelessWidget {
  const AdminPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          // Local title row (works inside AdminHome)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Payments Management',
                  style: TextStyle(
                    color: AppColors.title,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersRef
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text('No payments yet'));
                }

                final docs = snap.data!.docs;

                double totalCollected = 0;
                double totalPending = 0;
                int onlinePaid = 0;
                int codPaid = 0;

                for (final d in docs) {
                  final data = d.data() as Map<String, dynamic>;
                  final total = (data['total'] ?? 0).toDouble();
                  final status = data['paymentStatus'] ?? 'Pending';
                  final method = data['paymentMethod'] ?? 'Unknown';

                  if (status == 'Payment done' || status == 'Paid') {
                    totalCollected += total;
                    if (method.contains('Online')) {
                      onlinePaid++;
                    } else {
                      codPaid++;
                    }
                  } else if (status == 'Pending') {
                    totalPending += total;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _summaryRow(
                        totalCollected: totalCollected,
                        totalPending: totalPending,
                        onlinePaid: onlinePaid,
                        codPaid: codPaid,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final minWidth =
                              constraints.maxWidth < 600
                                  ? 600.0
                                  : constraints.maxWidth;
                              return Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: minWidth,
                                    ),
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        headingRowColor:
                                        MaterialStateProperty.all(
                                          AppColors.primarySoft,
                                        ),
                                        columnSpacing: 24,
                                        dataRowHeight: 60,
                                        columns: const [
                                          DataColumn(
                                            label: Text(
                                              'Order',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'User',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Date',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Method',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Payment Status',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Text(
                                              'Total (৳)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: docs.map((doc) {
                                          final data = doc.data()
                                          as Map<String, dynamic>;
                                          final orderId =
                                          doc.id.substring(0, 8);
                                          final userName =
                                              data['userName'] ?? 'Unknown';
                                          final ts =
                                          data['createdAt'] as Timestamp?;
                                          final date = ts != null
                                              ? ts.toDate().toLocal()
                                              : DateTime.now();
                                          final method =
                                              data['paymentMethod'] ??
                                                  'Unknown';
                                          final status =
                                              data['paymentStatus'] ??
                                                  'Pending';
                                          final total =
                                          (data['total'] ?? 0).toDouble();

                                          Color statusBg;
                                          Color statusText;

                                          if (status == 'Payment done' ||
                                              status == 'Paid') {
                                            statusBg = Colors.green.shade50;
                                            statusText = Colors.green.shade700;
                                          } else if (status == 'Failed') {
                                            statusBg = Colors.red.shade50;
                                            statusText = Colors.red.shade700;
                                          } else {
                                            statusBg = Colors.orange.shade50;
                                            statusText =
                                                Colors.orange.shade700;
                                          }

                                          IconData methodIcon;
                                          Color methodColor;
                                          if (method.contains('Online')) {
                                            methodIcon =
                                                Icons.wifi_tethering;
                                            methodColor = AppColors.primary;
                                          } else if (method.contains('Cash')) {
                                            methodIcon =
                                                Icons.delivery_dining;
                                            methodColor =
                                                Colors.brown.shade600;
                                          } else {
                                            methodIcon = Icons.payment;
                                            methodColor =
                                                AppColors.subtitle;
                                          }

                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  '#$orderId',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  userName,
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${date.day}/${date.month}/${date.year}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    Icon(
                                                      methodIcon,
                                                      size: 16,
                                                      color: methodColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        method,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                        const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusBg,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        16),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color: statusText,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  total.toStringAsFixed(0),
                                                  style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color: AppColors.title,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required double totalCollected,
    required double totalPending,
    required int onlinePaid,
    required int codPaid,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 700;
        if (isSmall) {
          // Stack cards vertically on small screens
          return Column(
            children: [
              _summaryCard(
                title: 'Collected',
                subtitle: 'All paid orders',
                value: '৳${totalCollected.toStringAsFixed(0)}',
                color: Colors.green.shade700,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 8),
              _summaryCard(
                title: 'Pending',
                subtitle: 'Awaiting payment',
                value: '৳${totalPending.toStringAsFixed(0)}',
                color: Colors.orange.shade700,
                icon: Icons.timelapse,
              ),
              const SizedBox(height: 8),
              _summaryCard(
                title: 'Paid orders',
                subtitle: 'Online / COD',
                value: '$onlinePaid online • $codPaid COD',
                color: AppColors.primary,
                icon: Icons.payments_outlined,
              ),
            ],
          );
        }

        // Row layout for larger screens
        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Collected',
                subtitle: 'All paid orders',
                value: '৳${totalCollected.toStringAsFixed(0)}',
                color: Colors.green.shade700,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                title: 'Pending',
                subtitle: 'Awaiting payment',
                value: '৳${totalPending.toStringAsFixed(0)}',
                color: Colors.orange.shade700,
                icon: Icons.timelapse,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                title: 'Paid orders',
                subtitle: 'Online / COD',
                value: '$onlinePaid online • $codPaid COD',
                color: AppColors.primary,
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

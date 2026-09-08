import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../colors.dart';

class AdminSalesReportPage extends StatefulWidget {
  const AdminSalesReportPage({super.key});

  @override
  State<AdminSalesReportPage> createState() => _AdminSalesReportPageState();
}

class _AdminSalesReportPageState extends State<AdminSalesReportPage> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          // Title + date filters (works inside AdminHome)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Analytics',
                  style: TextStyle(
                    color: AppColors.title,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _dateFilterBar(),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(child: _buildOrdersTable()),
        ],
      ),
    );
  }

  Widget _dateFilterBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        final children = [
          Expanded(
            child: _dateBox(
              label: 'From',
              date: startDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => startDate = picked);
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dateBox(
              label: 'To',
              date: endDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => endDate = picked);
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Clear dates',
            onPressed: () {
              setState(() {
                startDate = null;
                endDate = null;
              });
            },
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
        ];

        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Expanded(child: children[0])]),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: children[2])]),
              Align(
                alignment: Alignment.centerRight,
                child: children[4],
              ),
            ],
          );
        }

        return Row(children: children);
      },
    );
  }

  Widget _dateBox({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.subtitle,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTable() {
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true);

    if (startDate != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!),
      );
    }
    if (endDate != null) {
      query = query.where(
        'createdAt',
        isLessThanOrEqualTo:
        Timestamp.fromDate(endDate!.add(const Duration(days: 1))),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(child: Text('No orders in this range'));
        }

        final docs = snap.data!.docs;
        int deliveredCount = 0;
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if ((data['status'] ?? '') == 'Delivered') {
            deliveredCount++;
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              _summaryRow(
                totalOrders: docs.length,
                deliveredOrders: deliveredCount,
                docs: docs,
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
                      constraints.maxWidth < 900
                          ? 900.0
                          : constraints.maxWidth;
                      return Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: minWidth),
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  AppColors.bg,
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
                                      'Date',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    numeric: true,
                                    label: Text(
                                      'Items',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    numeric: true,
                                    label: Text(
                                      'Amount (৳)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Order Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Payment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: docs.map((doc) {
                                  final data =
                                  doc.data() as Map<String, dynamic>;
                                  final total =
                                  (data['total'] ?? 0).toDouble();
                                  final status =
                                      data['status'] ?? 'Pending';
                                  final paymentStatus =
                                      data['paymentStatus'] ?? 'Pending';
                                  final ts =
                                  data['createdAt'] as Timestamp?;
                                  final date = ts != null
                                      ? ts.toDate()
                                      : DateTime.now();
                                  final itemCount =
                                      (data['items'] as List?)?.length ?? 0;

                                  final bool delivered =
                                      status == 'Delivered';
                                  final bool failed =
                                      paymentStatus == 'Failed';

                                  Color statusBg;
                                  Color statusText;
                                  if (delivered) {
                                    statusBg = Colors.green.shade50;
                                    statusText = Colors.green.shade700;
                                  } else {
                                    statusBg = Colors.orange.shade50;
                                    statusText = Colors.orange.shade700;
                                  }

                                  Color payBg;
                                  Color payText;
                                  if (failed) {
                                    payBg = Colors.red.shade50;
                                    payText = Colors.red.shade700;
                                  } else if (paymentStatus ==
                                      'Payment done' ||
                                      paymentStatus == 'Paid') {
                                    payBg = Colors.green.shade50;
                                    payText = Colors.green.shade700;
                                  } else {
                                    payBg = Colors.grey.shade100;
                                    payText = Colors.grey.shade700;
                                  }

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '#${doc.id.substring(0, 8)}',
                                              style: const TextStyle(
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              data['userName'] ??
                                                  'Unknown user',
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.subtitle,
                                              ),
                                            ),
                                          ],
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
                                        Text(
                                          '$itemCount',
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          total.toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.title,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusBg,
                                            borderRadius:
                                            BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: statusText,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: payBg,
                                            borderRadius:
                                            BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            paymentStatus,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: payText,
                                            ),
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
    );
  }

  Widget _summaryRow({
    required int totalOrders,
    required int deliveredOrders,
    required List<QueryDocumentSnapshot> docs,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 700;
        final cards = [
          _summaryCard(
            icon: Icons.receipt_long,
            title: 'Total Orders',
            value: '$totalOrders',
            color: AppColors.primary,
          ),
          _summaryCard(
            icon: Icons.local_shipping_outlined,
            title: 'Delivered',
            value: '$deliveredOrders',
            color: Colors.green.shade700,
          ),
        ];

        if (isSmall) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 8),
              cards[1],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 10),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    Widget? trailing,
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
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing,
          ],
        ],
      ),
    );
  }

  Future<void> _generateSalesReportPDF(
      List<QueryDocumentSnapshot> docs,
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Sales Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Total Orders:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text('${docs.length}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Order Details',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _pdfHeaderCell('Order ID'),
                    _pdfHeaderCell('Date'),
                    _pdfHeaderCell('Items'),
                    _pdfHeaderCell('Amount'),
                    _pdfHeaderCell('Status'),
                  ],
                ),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final total = (data['total'] ?? 0).toDouble();
                  final status = data['status'] ?? 'Pending';
                  final ts = data['createdAt'] as Timestamp?;
                  final date =
                  ts != null ? ts.toDate() : DateTime.now();
                  final itemCount =
                      (data['items'] as List?)?.length ?? 0;

                  return pw.TableRow(
                    children: [
                      _pdfCell(doc.id.substring(0, 8)),
                      _pdfCell(
                        '${date.day}/${date.month}/${date.year}',
                      ),
                      _pdfCell('$itemCount'),
                      _pdfCell('৳${total.toStringAsFixed(0)}'),
                      _pdfCell(status),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  pw.Widget _pdfHeaderCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    ),
  );

  pw.Widget _pdfCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text),
  );
}

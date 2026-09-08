// lib/pages/order_receipt_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../colors.dart';

class OrderReceiptPage extends StatelessWidget {
  final QueryDocumentSnapshot orderDoc;

  const OrderReceiptPage({super.key, required this.orderDoc});

  @override
  Widget build(BuildContext context) {
    final data = orderDoc.data() as Map<String, dynamic>;
    final total = (data['total'] ?? 0).toDouble();
    final status = data['status'] ?? 'Pending';
    final paymentStatus = data['paymentStatus'] ?? 'Pending';
    final paymentMethod = data['paymentMethod'] ?? 'Cash on delivery';
    final ts = data['createdAt'] as Timestamp?;
    final date = ts != null ? ts.toDate() : DateTime.now();
    final items = (data['items'] as List<dynamic>? ?? []);

    Color statusColor = AppColors.warning;
    if (status == 'Delivered') statusColor = AppColors.success;
    if (status == 'Cancelled') statusColor = AppColors.danger;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Order Receipt'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _generateAndDownloadPDF(
                context,
                orderDoc.id,
                date,
                status,
                paymentStatus,
                paymentMethod,
                items,
                total,
              );
            },
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${orderDoc.id.substring(0, 8)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.title,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day} ${_monthName(date.month)} ${date.year}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subtitle,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Payment Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Status',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.subtitle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              paymentStatus,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.subtitle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              paymentMethod,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Items
                  const Text(
                    'Items Ordered',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.asMap().entries.map((entry) {
                    int idx = entry.key;
                    final item = entry.value;
                    final name = item['name'] ?? 'Unknown';
                    final qty = item['qty'] ?? 1;
                    final price = (item['price'] ?? 0).toDouble();
                    final itemTotal = price * qty;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.title,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qty: $qty',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.subtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '৳${itemTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.title,
                                ),
                              ),
                              Text(
                                '@ ৳${price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.subtitle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.bg),
                  const SizedBox(height: 16),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtitle,
                        ),
                      ),
                      Text(
                        '৳${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndDownloadPDF(
      BuildContext context,
      String orderId,
      DateTime date,
      String status,
      String paymentStatus,
      String paymentMethod,
      List<dynamic> items,
      double total,
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
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MediShop',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Dhaka, Bangladesh',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Order Receipt',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Order #${orderId.substring(0, 8)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Order Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${date.day}/${date.month}/${date.year}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Status',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(status),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Payment',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('$paymentStatus · $paymentMethod'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Items Ordered',
              style:
              pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...items.map((item) {
                  final name = item['name'] ?? 'Unknown';
                  final qty = item['qty'] ?? 1;
                  final price = (item['price'] ?? 0).toDouble();
                  final itemTotal = price * qty;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(name),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('$qty'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('৳${price.toStringAsFixed(0)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('৳${itemTotal.toStringAsFixed(0)}'),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Amount:'),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '৳${total.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Text(
              'Thank you for your order!',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'order_${orderId.substring(0, 8)}.pdf',
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

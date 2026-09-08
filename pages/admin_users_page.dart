import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../colors.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');

    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          // Header bar with title + add button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'User Management',
                    style: TextStyle(
                      color: AppColors.title,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => _showAddUserDialog(context),
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text(
                    'Add user',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.orderBy('firstName').snapshots(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text('No users'));
                }
                final docs = snap.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(16),
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
                              constraints: BoxConstraints(
                                minWidth: minWidth,
                              ),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor:
                                  MaterialStateProperty.all(
                                    AppColors.primarySoft,
                                  ),
                                  columnSpacing: 22,
                                  dataRowMinHeight: 60,
                                  dataRowMaxHeight: 70,
                                  showCheckboxColumn: false,
                                  columns: const [
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
                                        'Email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Phone',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Address',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Role',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: docs.map((u) {
                                    final data =
                                    u.data() as Map<String, dynamic>;
                                    final name =
                                    '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                                        .trim();
                                    final email = data['email'] ?? '';
                                    final phone = data['phone'] ?? '';
                                    final address = data['address'] ?? '';
                                    final role = data['role'] ?? 'user';
                                    final bool isAdmin = role == 'admin';

                                    Color roleBg;
                                    Color roleText;
                                    String roleLabel;

                                    if (isAdmin) {
                                      roleBg = Colors.deepPurple.shade50;
                                      roleText =
                                          Colors.deepPurple.shade700;
                                      roleLabel = 'Admin';
                                    } else {
                                      roleBg = Colors.green.shade50;
                                      roleText = Colors.green.shade700;
                                      roleLabel = 'Customer';
                                    }

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor:
                                                AppColors.primarySoft,
                                                child: Text(
                                                  (name.isNotEmpty
                                                      ? name[0]
                                                      : 'U')
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight:
                                                    FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      name.isEmpty
                                                          ? 'Unnamed user'
                                                          : name,
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style:
                                                      const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color:
                                                        AppColors.title,
                                                      ),
                                                    ),
                                                    if (email.isNotEmpty)
                                                      const SizedBox(
                                                        height: 2,
                                                      ),
                                                    if (email.isNotEmpty)
                                                      Text(
                                                        email,
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        style:
                                                        const TextStyle(
                                                          fontSize: 11,
                                                          color: AppColors
                                                              .subtitle,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              email,
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.title,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              phone.isEmpty
                                                  ? '—'
                                                  : phone,
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.subtitle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 220,
                                            child: Text(
                                              address.isEmpty
                                                  ? 'No address'
                                                  : address,
                                              maxLines: 2,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.subtitle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: roleBg,
                                              borderRadius:
                                              BorderRadius.circular(18),
                                            ),
                                            child: Text(
                                              roleLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                FontWeight.w600,
                                                color: roleText,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.visibility_outlined,
                                                  size: 20,
                                                  color:
                                                  AppColors.primaryDark,
                                                ),
                                                tooltip: 'View orders',
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          _UserOrdersForAdmin(
                                                            userId: u.id,
                                                            userName: name
                                                                .isEmpty
                                                                ? 'User'
                                                                : name,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              if (!isAdmin)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: AppColors.danger,
                                                  ),
                                                  tooltip: 'Delete user',
                                                  onPressed: () async {
                                                    final confirmed =
                                                    await showDialog<
                                                        bool>(
                                                      context: context,
                                                      builder: (_) =>
                                                          AlertDialog(
                                                            title: const Text(
                                                              'Delete user',
                                                            ),
                                                            content: Text(
                                                              'Delete "$name"? This will remove the user record.',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                                child:
                                                                const Text(
                                                                  'Cancel',
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                  AppColors
                                                                      .danger,
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                                child:
                                                                const Text(
                                                                  'Delete',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                    if (confirmed ==
                                                        true) {
                                                      await usersRef
                                                          .doc(u.id)
                                                          .delete();
                                                    }
                                                  },
                                                ),
                                            ],
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context) async {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Add user'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(firstCtrl, 'First name'),
                _field(lastCtrl, 'Last name'),
                _field(emailCtrl, 'Email'),
                _field(phoneCtrl, 'Phone'),
                _field(addrCtrl, 'Address'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final db = FirebaseFirestore.instance;
              await db.collection('users').add({
                'firstName': firstCtrl.text.trim(),
                'lastName': lastCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'address': addrCtrl.text.trim(),
                'role': 'user',
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}

class _UserOrdersForAdmin extends StatelessWidget {
  final String userId;
  final String userName;

  const _UserOrdersForAdmin({
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Orders of $userName'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
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
              final data = o.data() as Map<String, dynamic>;
              final total = (data['total'] ?? 0).toDouble();
              final status = data['status'] ?? 'Pending';
              final paymentStatus = data['paymentStatus'] ?? 'Pending';
              final ts = data['createdAt'] as Timestamp?;
              final date =
              ts != null ? ts.toDate().toLocal() : DateTime.now();

              Color statusColor = AppColors.warning;
              if (status == 'Delivered') statusColor = AppColors.success;
              if (status == 'Cancelled') statusColor = AppColors.danger;

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
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
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
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed: $date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
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
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                            'Payment: $paymentStatus',
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
      ),
    );
  }
}

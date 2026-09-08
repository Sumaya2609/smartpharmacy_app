import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/firestore_stock_controller.dart';
import '../models/medicine_model.dart';
import '../colors.dart';

class AdminProductListPage extends StatelessWidget {
  AdminProductListPage({super.key});

  final FirestoreStockController stock = Get.find<FirestoreStockController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final List<Medicine> meds = stock.medicines;
          if (meds.isEmpty) {
            return const Center(child: Text('No medicines found'));
          }

          return Container(
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
            child: Column(
              children: [
                _headerBar(meds.length),
                const Divider(height: 1),
                Expanded(
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
                                dataRowHeight: 70,
                                columnSpacing: 18,
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Medicine',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Strength / Brand',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    numeric: true,
                                    label: Text(
                                      'Price (৳)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Stock',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Description',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Side effects',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ingredients',
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
                                rows: meds
                                    .map((m) => _buildRow(context, m))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _headerBar(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.medication_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Total medicines: $count',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.title,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tap any cell to edit',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, Medicine m) {
    final bool outOfStock = m.stock <= 0;
    final bool lowStock = m.stock > 0 && m.stock <= 5;

    Color stockBg;
    Color stockText;
    String stockLabel;

    if (outOfStock) {
      stockBg = Colors.red.shade50;
      stockText = Colors.red.shade700;
      stockLabel = 'Out of stock';
    } else if (lowStock) {
      stockBg = Colors.orange.shade50;
      stockText = Colors.orange.shade700;
      stockLabel = 'Low • ${m.stock} left';
    } else {
      stockBg = Colors.green.shade50;
      stockText = Colors.green.shade700;
      stockLabel = '${m.stock} in stock';
    }

    return DataRow(
      cells: [
        // Medicine name + ID snippet
        DataCell(
          InkWell(
            onTap: () => _editField(context, m, 'name', m.name),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  m.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${m.id.substring(0, 6)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Strength / Brand
        DataCell(
          InkWell(
            onTap: () => _editField(context, m, 'brand', m.brand),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.strength,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m.brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Price
        DataCell(
          Text(
            m.price.toStringAsFixed(0),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),

        // Stock chip
        DataCell(
          InkWell(
            onTap: () => _editStock(context, m),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: stockBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                stockLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: stockText,
                ),
              ),
            ),
          ),
        ),

        // Description
        DataCell(
          InkWell(
            onTap: () => _editField(
              context,
              m,
              'description',
              m.description,
            ),
            child: SizedBox(
              width: 200,
              child: Text(
                m.description.isEmpty
                    ? 'Tap to add description'
                    : m.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: m.description.isEmpty
                      ? AppColors.subtitle
                      : AppColors.title,
                ),
              ),
            ),
          ),
        ),

        // Side effects
        DataCell(
          InkWell(
            onTap: () => _editField(
              context,
              m,
              'sideEffects',
              m.sideEffects,
            ),
            child: SizedBox(
              width: 180,
              child: Text(
                m.sideEffects.isEmpty ? 'Tap to add' : m.sideEffects,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: m.sideEffects.isEmpty
                      ? AppColors.subtitle
                      : AppColors.title,
                ),
              ),
            ),
          ),
        ),

        // Ingredients
        DataCell(
          InkWell(
            onTap: () => _editField(
              context,
              m,
              'ingredients',
              m.ingredients,
            ),
            child: SizedBox(
              width: 180,
              child: Text(
                m.ingredients.isEmpty ? 'Tap to add' : m.ingredients,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: m.ingredients.isEmpty
                      ? AppColors.subtitle
                      : AppColors.title,
                ),
              ),
            ),
          ),
        ),

        // Actions (edit + delete)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note_outlined),
                tooltip: 'Edit all fields',
                onPressed: () => _openFullEditDialog(context, m),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete medicine',
                onPressed: () => _confirmDelete(context, m),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Medicine med) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete medicine'),
        content: Text(
          'Are you sure you want to delete "${med.name}"? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await stock.deleteMedicine(med.id);
    }
  }

  void _editField(
      BuildContext context,
      Medicine med,
      String field,
      String initialValue, {
        bool isNumber = false,
      }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: isNumber ? 1 : null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    await stock.updateMedicineField(
      medId: med.id,
      field: field,
      value: result,
    );
  }

  Future<void> _editStock(BuildContext context, Medicine med) async {
    final controller = TextEditingController(text: med.stock.toString());

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit stock quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter new stock quantity',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;

    final newStock = int.tryParse(result) ?? med.stock;

    final updated = Medicine(
      id: med.id,
      name: med.name,
      brand: med.brand,
      categoryId: med.categoryId,
      image: med.image,
      strength: med.strength,
      stock: newStock,
      price: med.price,
      ingredients: med.ingredients,
      sideEffects: med.sideEffects,
      description: med.description,
      rating: med.rating,
    );

    await stock.updateMedicine(med.id, updated);
  }

  void _openFullEditDialog(BuildContext context, Medicine med) {
    // You can add a bigger form here later if needed.
  }
}

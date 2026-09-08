// lib/pages/stock_management_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../controllers/firestore_stock_controller.dart';
import '../models/medicine_model.dart';

class StockManagementPage extends StatelessWidget {
  StockManagementPage({super.key});

  final FirestoreStockController stock = Get.find<FirestoreStockController>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController brandCtrl = TextEditingController();
  final TextEditingController strengthCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();
  final TextEditingController imageCtrl =
  TextEditingController(text: 'assets/medicine1.png');

  void _openAddCategoryDialog() {
    final TextEditingController catCtrl = TextEditingController();
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Add Category'),
        content: TextField(
          controller: catCtrl,
          decoration: const InputDecoration(
            labelText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final name = catCtrl.text.trim();
              if (name.isEmpty) return;
              await stock.addCategory(name);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openAddMedicineDialog(BuildContext context) {
    if (stock.selectedCategoryId.isEmpty) {
      Get.snackbar('Select category', 'Please select a category first');
      return;
    }

    nameCtrl.clear();
    brandCtrl.clear();
    strengthCtrl.clear();
    priceCtrl.clear();
    stockCtrl.clear();
    imageCtrl.text = 'assets/medicine1.png';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Add Medicine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Name'),
              _field(brandCtrl, 'Brand'),
              _field(strengthCtrl, 'Strength (e.g. 10 mg)'),
              _field(
                priceCtrl,
                'Price',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
              _field(
                stockCtrl,
                'Stock',
                keyboard: TextInputType.number,
              ),
              _field(
                imageCtrl,
                'Image asset path',
                helper: 'e.g. assets/medicine1.png',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              final qty = int.tryParse(stockCtrl.text.trim()) ?? 0;

              final med = Medicine(
                id: '',
                name: nameCtrl.text.trim(),
                brand: brandCtrl.text.trim(),
                strength: strengthCtrl.text.trim(),
                categoryId: stock.selectedCategoryId.value,
                price: price,
                stock: qty,
                image: imageCtrl.text.trim(),
              );

              stock.addMedicine(med);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static Widget _field(
      TextEditingController c,
      String label, {
        TextInputType keyboard = TextInputType.text,
        String? helper,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Stock Management'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openAddMedicineDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category selector
            Row(
              children: [
                Expanded(
                  child: Obx(
                        () => DropdownButtonFormField<String>(
                      value: stock.selectedCategoryId.value.isEmpty
                          ? null
                          : stock.selectedCategoryId.value,
                      hint: const Text('Select Category'),
                      items: stock.categories
                          .map(
                            (c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                          .toList(),
                      onChanged: (id) {
                        stock.selectedCategoryId.value = id ?? '';
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _openAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  color: AppColors.primary,
                  tooltip: 'Add Category',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Medicines list
            Expanded(
              child: Obx(() {
                final meds = stock.filteredMedicines;
                if (meds.isEmpty) {
                  return const Center(child: Text('No medicines'));
                }
                return ListView.builder(
                  itemCount: meds.length,
                  itemBuilder: (_, i) {
                    final m = meds[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            m.image,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          m.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.title,
                          ),
                        ),
                        subtitle: Text(
                          '${m.brand} • ${m.strength}\n৳${m.price.toStringAsFixed(0)}  |  Stock: ${m.stock}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.danger,
                          ),
                          onPressed: () => stock.deleteMedicine(m.id),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

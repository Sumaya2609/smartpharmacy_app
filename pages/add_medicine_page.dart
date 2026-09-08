// lib/pages/add_medicine_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../controllers/firestore_stock_controller.dart';
import '../models/category_model.dart';
import '../models/medicine_model.dart';

class AddMedicinePage extends StatelessWidget {
  final CategoryModel category;

  AddMedicinePage({super.key, required this.category});

  final FirestoreStockController stock = Get.find<FirestoreStockController>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController brandCtrl = TextEditingController();
  final TextEditingController strengthCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Add Medicine'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Category: ${category.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.subtitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field('Medicine Name', nameCtrl),
                  _field('Brand', brandCtrl),
                  _field('Strength (mg)', strengthCtrl),
                  _field('Price', priceCtrl, isNumber: true),
                  _field('Stock Quantity', stockCtrl, isNumber: true),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        final price =
                            double.tryParse(priceCtrl.text.trim()) ?? 0;
                        final qty =
                            int.tryParse(stockCtrl.text.trim()) ?? 0;

                        final med = Medicine(
                          id: '',
                          categoryId: category.id,
                          name: nameCtrl.text.trim(),
                          brand: brandCtrl.text.trim(),
                          strength: strengthCtrl.text.trim(),
                          image: 'assets/medicine.png',
                          price: price,
                          stock: qty,
                        );

                        stock.addMedicine(med);
                        Get.back();
                      },
                      child: const Text('Add Medicine'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController ctrl, {
        bool isNumber = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

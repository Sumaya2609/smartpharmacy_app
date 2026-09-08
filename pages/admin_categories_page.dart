// lib/pages/admin_categories_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/firestore_stock_controller.dart';
import '../models/category_model.dart';
import '../colors.dart';
import 'add_medicine_page.dart';

class AdminCategoriesPage extends StatelessWidget {
  AdminCategoriesPage({super.key});

  final FirestoreStockController stock = Get.find<FirestoreStockController>();
  final TextEditingController nameCtrl = TextEditingController();

  void _addCategoryDialog() {
    nameCtrl.clear();
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
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

  void _editCategoryDialog(CategoryModel cat) {
    nameCtrl.text = cat.name;
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              await stock.db
                  .collection('categories')
                  .doc(cat.id)
                  .update({'name': name});
              Get.back();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel cat) async {
    await stock.db.collection('categories').doc(cat.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategoryDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (stock.categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
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
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.category_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Total categories: ${stock.categories.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.title,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: stock.categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final cat = stock.categories[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primarySoft,
                          child: Text(
                            cat.name.isNotEmpty
                                ? cat.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.title,
                          ),
                        ),
                        subtitle: const Text(
                          'Tap + to add medicine in this category',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.subtitle,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Add medicine',
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                Get.to(() => AddMedicinePage(category: cat));
                              },
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editCategoryDialog(cat),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deleteCategory(cat),
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
        }),
      ),
    );
  }
}

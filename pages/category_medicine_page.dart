import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/firestore_stock_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/category_model.dart';
import '../colors.dart';
import 'medicine_details_page.dart';

class CategoryMedicinePage extends StatelessWidget {
  final CategoryModel category;
  CategoryMedicinePage({super.key, required this.category});

  final FirestoreStockController stock = Get.find<FirestoreStockController>();
  final CartController cart = Get.find<CartController>();

  int _crossAxisCountForWidth(double width) {
    if (width >= 1000) return 4; // desktop / big tablet
    if (width >= 700) return 3;  // tablet
    return 2;                    // phones
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: Obx(() {
                final meds = stock.medicines
                    .where((m) => m.categoryId == category.id)
                    .toList();

                if (meds.isEmpty) {
                  return const Center(child: Text("No medicines"));
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                    _crossAxisCountForWidth(constraints.maxWidth);
                    return GridView.builder(
                      padding: const EdgeInsets.all(14),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.70,
                      ),
                      itemCount: meds.length,
                      itemBuilder: (_, i) {
                        final m = meds[i];
                        return GestureDetector(
                          onTap: () =>
                              Get.to(() => MedicineDetailsPage(medicine: m)),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      height: 80,
                                      child: Image.asset(
                                        m.image,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                  m.strength,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subtitle,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "৳${m.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cart.addToCart(m);
                                      Get.snackbar(
                                        "Added",
                                        "${m.name} added",
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      minimumSize: const Size.fromHeight(34),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Add",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

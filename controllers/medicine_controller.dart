// lib/controllers/medicine_controller.dart
import 'package:get/get.dart';
import 'firestore_stock_controller.dart';
import '../models/category_model.dart';
import '../models/medicine_model.dart';

class MedicineController extends GetxController {
  final FirestoreStockController stock =
  Get.find<FirestoreStockController>();

  RxList<CategoryModel> get categories => stock.categories;

  List<Medicine> get medicines => stock.medicines;

  List<Medicine> medicinesByCategory(String catId) {
    return stock.medicines
        .where((m) => m.categoryId == catId)
        .toList();
  }
}

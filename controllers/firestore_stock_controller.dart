// lib/controllers/firestore_stock_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../models/medicine_model.dart';

class FirestoreStockController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<Medicine> medicines = <Medicine>[].obs;
  final RxList<Medicine> filteredMedicines = <Medicine>[].obs;

  final RxString selectedCategoryId = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();

    db.collection('categories').snapshots().listen((snap) {
      final list = snap.docs
          .map((d) => CategoryModel.fromDoc(d.data(), d.id))
          .toList();
      categories.assignAll(list);
    });

    db.collection('medicines').snapshots().listen((snap) {
      final list = snap.docs
          .map((d) => Medicine.fromDoc(d.data(), d.id))
          .toList();
      medicines.assignAll(list);
      _applyFilters();
    });

    everAll([selectedCategoryId, searchQuery], (_) => _applyFilters());
  }

  void _applyFilters() {
    var list = medicines.toList();

    if (selectedCategoryId.isNotEmpty) {
      list = list
          .where((m) => m.categoryId == selectedCategoryId.value)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((m) =>
      m.name.toLowerCase().contains(q) ||
          m.brand.toLowerCase().contains(q))
          .toList();
    }

    filteredMedicines.assignAll(list);
  }

  // Get current stock for a medicine
  Stream<int> getStockStream(String medicineId) {
    return db.collection('medicines').doc(medicineId).snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['stock'] ?? 0) as int;
    });
  }

  // Check if medicine is available
  bool isMedicineAvailable(Medicine medicine, {int quantity = 1}) {
    return medicine.stock >= quantity && medicine.stock > 0;
  }

  Future<void> addCategory(String name) {
    return db.collection('categories').add({'name': name});
  }

  Future<void> addMedicine(Medicine m) {
    return db.collection('medicines').add(m.toMap());
  }

  Future<void> updateMedicine(String id, Medicine m) async {
    final docRef = db.collection('medicines').doc(id);

    final prevSnap = await docRef.get();
    final prevData = prevSnap.data() as Map<String, dynamic>?;
    final int prevStock = (prevData?['stock'] ?? 0) is int
        ? (prevData?['stock'] ?? 0) as int
        : int.tryParse((prevData?['stock'] ?? '0').toString()) ?? 0;
    final int newStock = m.stock;

    await docRef.update(m.toMap());

    if (prevStock <= 0 && newStock > 0) {
      final subsSnap = await db
          .collectionGroup('restock_subscriptions')
          .where('medicineId', isEqualTo: id)
          .get();

      final batch = db.batch();

      for (final sub in subsSnap.docs) {
        final userId = sub.reference.parent.parent!.id;

        final notifRef = db
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc();

        batch.set(notifRef, {
          'title': 'Medicine available',
          'body': '${m.name} is back in stock.',
          'medicineId': id,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });

        batch.delete(sub.reference);
      }

      await batch.commit();
    }
  }

  Future<void> updateMedicineField({
    required String medId,
    required String field,
    required dynamic value,
  }) async {
    await db.collection('medicines').doc(medId).update({field: value});
  }

  Future<void> deleteMedicine(String id) {
    return db.collection('medicines').doc(id).delete();
  }

  Future<void> addRecentSearch(String userId, String medicineId) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('recent_searches')
        .doc(medicineId)
        .set({
      'medicineId': medicineId,
      'searchedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> recentSearchesStream(String userId) {
    return db
        .collection('users')
        .doc(userId)
        .collection('recent_searches')
        .orderBy('searchedAt', descending: true)
        .limit(10)
        .snapshots();
  }
}

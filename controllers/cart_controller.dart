// lib/controllers/cart_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/medicine_model.dart';

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});

  double get total => medicine.price * quantity;
}

class CartController extends GetxController {
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  final GetStorage _box = GetStorage();
  final String _key = 'cartItems';

  @override
  void onInit() {
    super.onInit();
    _restoreCart();
    ever<List<CartItem>>(cartItems, (_) => _saveCart());
  }

  bool addToCart(Medicine med) {
    // ✅ Check stock before adding
    if (med.stock <= 0) {
      Get.snackbar(
        'Out of Stock',
        '${med.name} is currently out of stock!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      return false;
    }

    final index = cartItems.indexWhere((c) => c.medicine.id == med.id);
    if (index == -1) {
      if (med.stock >= 1) {
        cartItems.add(CartItem(medicine: med));
        return true;
      } else {
        Get.snackbar(
          'Limited Stock',
          'Only ${med.stock} left!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    } else {
      // ✅ Check if increasing exceeds stock
      final newQty = cartItems[index].quantity + 1;
      if (newQty > med.stock) {
        Get.snackbar(
          'Limited Stock ⚠️',
          'Only ${med.stock} available!\nCurrent: ${cartItems[index].quantity}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }
      cartItems[index].quantity++;
      cartItems.refresh();
      return true;
    }
  }

  void changeQuantity(CartItem item, int delta) {
    final newQuantity = item.quantity + delta;

    // Proper stock validation with SNACKBAR
    if (newQuantity > item.medicine.stock) {
      Get.snackbar(
        'Stock Limit Reached! 🚫',
        'Only ${item.medicine.stock} left in stock\nCurrent: ${item.quantity}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
      return; // ❌ DON'T allow increase
    }

    if (newQuantity <= 0) {
      cartItems.remove(item);
    } else {
      item.quantity = newQuantity;
      cartItems.refresh();
    }
  }

  double get total => cartItems.fold(0, (sum, item) => sum + item.total);

  bool get hasOutOfStockItems =>
      cartItems.any((item) => item.medicine.stock < item.quantity);

  bool get canCheckout =>
      !hasOutOfStockItems && cartItems.isNotEmpty;

  void clear() => cartItems.clear();

  void _saveCart() {
    final data = cartItems.map((ci) => {
      'medicine': ci.medicine.toMap()..['id'] = ci.medicine.id,
      'quantity': ci.quantity,
    }).toList();
    _box.write(_key, data);
  }

  void _restoreCart() {
    final List<dynamic>? data = _box.read<List>(_key);
    if (data == null) return;
    final restored = data.map((e) {
      final map = Map<String, dynamic>.from(e);
      final medMap = Map<String, dynamic>.from(map['medicine'] as Map);
      final id = medMap['id'] as String;
      medMap.remove('id');
      final med = Medicine.fromDoc(medMap, id);
      return CartItem(medicine: med, quantity: map['quantity'] as int);
    }).toList();
    cartItems.assignAll(restored);
  }
}

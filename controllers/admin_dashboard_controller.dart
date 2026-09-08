import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isSidebarOpen = true.obs;
  final RxInt selectedIndex = 0
      .obs; // 0 = Dashboard, 1..n = other pages

  final RxInt totalUsers = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt medicines = 0.obs;
  final RxInt pendingDeliveries = 0.obs;

  @override
  void onInit() {
    super.onInit();

    _db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .listen((snap) => totalUsers.value = snap.size);

    _db.collection('medicines').snapshots().listen(
          (snap) => medicines.value = snap.size,
    );

    _db.collection('orders').snapshots().listen((snap) {
      totalOrders.value = snap.size;
      pendingDeliveries.value = snap.docs
          .where((d) => d['status'] != 'Delivered')
          .length;
    });
  }

  void toggleSidebar() => isSidebarOpen.toggle();

  void changePage(int index) => selectedIndex.value = index;
}

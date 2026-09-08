import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'controllers/firestore_stock_controller.dart';
import 'controllers/medicine_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/user_profile_controller.dart';
import 'pages/intro_page.dart';
import 'pages/admin_login.dart';
import 'pages/admin_home.dart';
import 'pages/user_home.dart';
import 'pages/user_login.dart';
import 'pages/user_register.dart';
import 'pages/stock_management_page.dart';
import 'pages/cart_page.dart';
import 'pages/user_orders_page.dart';
import 'routes.dart';

Future<String> _getInitialRoute() async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  if (user == null) {
    return AppRoutes.intro;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()?['role'] == 'admin') {
      return AppRoutes.adminHome;
    }
  } catch (_) {
    // if role lookup fails, fall back to user home
  }

  return '/user-home';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Keep auth session across restarts (only supported on web)
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  await GetStorage.init();

  final initialRoute = await _getInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(FirestoreStockController(), permanent: true);
        Get.put(MedicineController(), permanent: true);
        Get.put(CartController(), permanent: true);
        Get.put(UserProfileController(), permanent: true);
      }),
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: AppRoutes.intro,
          page: () => const IntroPage(),
        ),
        GetPage(
          name: AppRoutes.adminLogin,
          page: () => const AdminLogin(),
        ),
        GetPage(
          name: AppRoutes.adminHome,
          page: () => AdminHome(),
        ),
        GetPage(
          name: '/user-home',
          page: () => UserHome(),
        ),
        GetPage(
          name: '/user-login',
          page: () => const UserLoginPage(),
        ),
        GetPage(
          name: AppRoutes.userRegister,
          page: () => const UserRegister(),
        ),
        GetPage(
          name: '/stock-management',
          page: () => StockManagementPage(),
        ),
        GetPage(
          name: '/cart',
          page: () => CartPage(),
        ),
        GetPage(
          name: '/user-orders',
          page: () => const UserOrdersPage(),
        ),
        GetPage
          (name: AppRoutes.cart,
            page: () => CartPage()),
      ],
    );
  }
}

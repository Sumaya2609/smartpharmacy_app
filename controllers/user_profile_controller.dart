// lib/controllers/user_profile_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/app_user.dart';

class UserProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  // NEW: unread notifications count
  final RxInt unreadNotifications = 0.obs;

  @override
  void onInit() {
    super.onInit();

    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        currentUser.value = null;
        unreadNotifications.value = 0;
        return;
      }

      // load profile
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        currentUser.value = AppUser.fromDoc(doc.data()!, doc.id);
      }

      // listen for unread notifications
      _db
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snap) {
        unreadNotifications.value = snap.docs.length;
      });
    });
  }

  Future register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    final user = AppUser(
      id: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      role: 'user',
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    currentUser.value = user;
  }

  Future login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future logout() async {
    await _auth.signOut();
  }

  Future updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'address': address,
    });

    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      currentUser.value = AppUser.fromDoc(doc.data()!, doc.id);
    }
  }
}

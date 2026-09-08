import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<String?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = result.user!.uid;

    final doc = await _db.collection("users").doc(uid).get();
    return doc["role"]; // returns 'admin' or 'user'
  }

  Future<void> registerUser(
      String email, String password, String role) async {
    final user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _db.collection("users").doc(user.user!.uid).set({
      "role": role,
      "email": email,
    });
  }
}

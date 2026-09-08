import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCkUk-_1FD0igTBFNBCGA67ezjRSXVqTrE",
    appId: "1:192083985236:android:e2365f510af672e3a27ec1",
    messagingSenderId: "192083985236",
    projectId: "smart-pharmacy-91e35",
    storageBucket: "smart-pharmacy-91e35.firebasestorage.app",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCkUk-_1FD0igTBFNBCGA67ezjRSXVqTrE",
    appId: "1:192083985236:web:smartpharmacy",
    messagingSenderId: "192083985236",
    projectId: "smart-pharmacy-91e35",
    storageBucket: "smart-pharmacy-91e35.firebasestorage.app",
  );
}

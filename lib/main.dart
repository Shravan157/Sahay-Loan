// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'app.dart';
// import 'core/services/storage_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase with options for web support
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: "AIzaSyCuz4MX4w1AJ43t8Ii_hUi3adWf9Mc3egw",
//       authDomain: "sahay-loan-app.firebaseapp.com",
//       projectId: "sahay-loan-app",
//       storageBucket: "sahay-loan-app.appspot.com",
//       messagingSenderId: "123456789",
//       appId: "1:123456789:web:abcdef123456",
//     ),
//   );
//
//   await StorageService().init();
//   runApp(const SahayApp());
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  await StorageService().init();
  runApp(const SahayApp());
}
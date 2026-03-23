import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      // Initialize Firebase with web options for Chrome/web support
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCuz4MX4w1AJ43t8Ii_hUi3adWf9Mc3egw",
            authDomain: "sahay-loan-app.firebaseapp.com",
            projectId: "sahay-loan-app",
            storageBucket: "sahay-loan-app.appspot.com",
            messagingSenderId: "1036677816108",
            appId: "1:1036677816108:web:abc123def456",
          ),
        );
      } else {
        // Mobile platforms use native configuration
        await Firebase.initializeApp();
      }
    }

    await StorageService().init();
    
    // Initialize Stripe for payments
    try {
      await PaymentService().initialize();
    } catch (e) {
      print('Payment service initialization failed: $e');
    }
    
    // Initialize FCM notifications
    try {
      await NotificationService().initialize();
    } catch (e) {
      print('Notification service initialization failed: $e');
    }
    
    runApp(const SahayApp());
  } catch (e) {
    // Show error if Firebase fails to initialize
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please check your Firebase configuration.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
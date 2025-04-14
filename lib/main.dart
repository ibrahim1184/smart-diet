import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/modules/auth/bindings/auth_binding.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase'i başlat
    if (Firebase.apps.isEmpty) {
      // Firebase zaten başlatılmış mı kontrol et
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "your-api-key",
          appId: "your-app-id",
          messagingSenderId: "your-sender-id",
          projectId: "your-project-id",
          storageBucket: "your-storage-bucket",
        ),
      );
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    GetMaterialApp(
      title: "Smart Diet",
      initialRoute: AppPages.INITIAL,
      initialBinding: AuthBinding(),
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}

// Debug modu kontrolü
bool get debugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

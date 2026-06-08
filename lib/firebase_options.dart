// Firebase configuration for Warranty Vault.
//
// These values come from the same Firebase project the React Native app used
// (.env -> EXPO_PUBLIC_FIREBASE_*). The web app credentials are public
// identifiers, not secrets — access is controlled by Firestore Security Rules.
//
// NOTE: the `android` entry currently reuses the web app credentials so the
// web preview and a quick device test work. Before building the production
// APK we'll run `flutterfire configure` to register a dedicated Android app
// and regenerate this file properly.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        // Web preview + Android are the only supported targets for now.
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAzmczKi0j_yOA5QrIT5DFkBi8CIgeveBU',
    appId: '1:916872583271:web:fb7eaf6e4940bce52adcc2',
    messagingSenderId: '916872583271',
    projectId: 'warrenty-management-b9396',
    authDomain: 'warrenty-management-b9396.firebaseapp.com',
    storageBucket: 'warrenty-management-b9396.firebasestorage.app',
  );

  // Placeholder: reuses web credentials until `flutterfire configure` runs.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzmczKi0j_yOA5QrIT5DFkBi8CIgeveBU',
    appId: '1:916872583271:web:fb7eaf6e4940bce52adcc2',
    messagingSenderId: '916872583271',
    projectId: 'warrenty-management-b9396',
    storageBucket: 'warrenty-management-b9396.firebasestorage.app',
  );
}

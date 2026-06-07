// Generated from google-services.json — Firebase project: trip-calc-110

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBPb9e9rIZNFpe2X_0Naf8CRqgA9xF6kCE',
    appId: '1:621029142110:web:baab4bf7a034afc6250ecf',
    messagingSenderId: '621029142110',
    projectId: 'trip-calc-110',
    authDomain: 'trip-calc-110.firebaseapp.com',
    storageBucket: 'trip-calc-110.firebasestorage.app',
    measurementId: 'G-25Z2KNHHJS',
    databaseURL: 'https://trip-calc-110-default-rtdb.firebaseio.com',
  );

  // Values from google-services.json → package: com.mycompany.captaintripcalculator
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC05OdatNgSSXtkYuiDOVXh87OtHAfMcM8',
    appId: '1:621029142110:android:be3ddfeee75a7eb9250ecf',
    messagingSenderId: '621029142110',
    projectId: 'trip-calc-110',
    storageBucket: 'trip-calc-110.firebasestorage.app',
    databaseURL: 'https://trip-calc-110-default-rtdb.firebaseio.com',
  );

  // Values from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrAiJ7qfuHPwSSdUkJa-bp9AC_nqUouK0',
    appId: '1:621029142110:ios:2fc672ba313eae46250ecf',
    messagingSenderId: '621029142110',
    projectId: 'trip-calc-110',
    storageBucket: 'trip-calc-110.firebasestorage.app',
    iosBundleId: 'com.mycompany.captainridecalc',
    databaseURL: 'https://trip-calc-110-default-rtdb.firebaseio.com',
  );
}

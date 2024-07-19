// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAX9k0zcIwLg0HV06lzr__Wwx5lgUz8eg',
    appId: '1:881635480065:web:21115c6fb713168fdf2600',
    messagingSenderId: '881635480065',
    projectId: 'granity-66ea1',
    authDomain: 'granity-66ea1.firebaseapp.com',
    storageBucket: 'granity-66ea1.appspot.com',
    measurementId: 'G-HVXCHE19K8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5xK7J_Hnw7L0WdlvTZTRLtSNZUEJabiw',
    appId: '1:881635480065:android:27bae55fe7c2c391df2600',
    messagingSenderId: '881635480065',
    projectId: 'granity-66ea1',
    storageBucket: 'granity-66ea1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5_q94QxdTN7DUUFg-vBZaZaxyg06qXZw',
    appId: '1:881635480065:ios:ab07a8cf7ff87c4bdf2600',
    messagingSenderId: '881635480065',
    projectId: 'granity-66ea1',
    storageBucket: 'granity-66ea1.appspot.com',
    iosBundleId: 'com.example.granity',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5_q94QxdTN7DUUFg-vBZaZaxyg06qXZw',
    appId: '1:881635480065:ios:ab07a8cf7ff87c4bdf2600',
    messagingSenderId: '881635480065',
    projectId: 'granity-66ea1',
    storageBucket: 'granity-66ea1.appspot.com',
    iosBundleId: 'com.example.granity',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAX9k0zcIwLg0HV06lzr__Wwx5lgUz8eg',
    appId: '1:881635480065:web:bca8bf64473af0c8df2600',
    messagingSenderId: '881635480065',
    projectId: 'granity-66ea1',
    authDomain: 'granity-66ea1.firebaseapp.com',
    storageBucket: 'granity-66ea1.appspot.com',
    measurementId: 'G-WD8JNCE3SG',
  );
}

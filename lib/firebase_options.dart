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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC8iDPaWVE_zB9FRQGAEvoidbm6An69bHw',
    appId: '1:11410147239:web:09e0c6620fdbd555491882',
    messagingSenderId: '11410147239',
    projectId: 'todoflutter-1f150',
    authDomain: 'todoflutter-1f150.firebaseapp.com',
    databaseURL: 'https://todoflutter-1f150-default-rtdb.firebaseio.com',
    storageBucket: 'todoflutter-1f150.firebasestorage.app',
    measurementId: 'G-0NY4WXH78K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBikVt99MFUbvN9hpOywipRkSrKDxfm7B4',
    appId: '1:11410147239:android:52f0c0b49a3eafa3491882',
    messagingSenderId: '11410147239',
    projectId: 'todoflutter-1f150',
    databaseURL: 'https://todoflutter-1f150-default-rtdb.firebaseio.com',
    storageBucket: 'todoflutter-1f150.firebasestorage.app',
  );
}

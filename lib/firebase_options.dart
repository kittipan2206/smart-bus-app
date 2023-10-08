// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyD0KbLLiqGfFhA4qtmT4KBZM2D2LqlK5OM',
    appId: '1:289143881277:web:891d48f406fb0565817454',
    messagingSenderId: '289143881277',
    projectId: 'smart-bus1-cbe0a',
    authDomain: 'smart-bus1-cbe0a.firebaseapp.com',
    storageBucket: 'smart-bus1-cbe0a.appspot.com',
    measurementId: 'G-PKDQGZR8NH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDyhMS1UoKofnKj9JN3Wu-5w1HY47cSn0c',
    appId: '1:289143881277:android:d84cc91c24912d37817454',
    messagingSenderId: '289143881277',
    projectId: 'smart-bus1-cbe0a',
    storageBucket: 'smart-bus1-cbe0a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdkbXEPVBWcDcfHFXeNa_ezAiH5UZLALk',
    appId: '1:289143881277:ios:c4c8c51d0fdf8ab5817454',
    messagingSenderId: '289143881277',
    projectId: 'smart-bus1-cbe0a',
    storageBucket: 'smart-bus1-cbe0a.appspot.com',
    iosClientId: '289143881277-bd3ne4v2k3ephbqgcsu1gcvne2m38ocs.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartBus',
  );
}

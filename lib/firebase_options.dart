import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB472zVtppPAGNZvZDjcwhe4CGkbgSy4Mw',
    authDomain: 'pcb-defect-2.firebaseapp.com',
    databaseURL: 'https://pcb-defect-2-default-rtdb.asia-southeast1.firebasedatabase.app',
    projectId: 'pcb-defect-2',
    storageBucket: 'pcb-defect-2.firebasestorage.app',
    messagingSenderId: '77116352899',
    appId: '1:77116352899:web:0259b5266335d4eb1a2eb6',
    measurementId: 'G-J5S4QN4Y3W',
  );
}

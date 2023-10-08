import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/services/firebase_services.dart';
// import 'package:smart_bus/presentation/shared_controller/location_controller.dart';

// final getIt = GetIt.instance;

Future<void> setUp() async {
  await getCurrentLocation();

  await FirebaseServices.streamBusLocation();
  await FirebaseServices.getBusList();

  isLogin.value = FirebaseAuth.instance.currentUser != null;
  if (isLogin.value) {
    // listen to user info
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((event) {
      userInfo.value = event.data()!;
    });
  }
}

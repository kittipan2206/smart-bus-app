import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/shared_controller/firebase_services.dart';
// import 'package:smart_bus/presentation/shared_controller/location_controller.dart';

// final getIt = GetIt.instance;

Future<void> setUp() async {
  await getCurrentLocation();

  await FirebaseServices.streamBusLocation();
  await FirebaseServices.getBusList();
  isLogin.value = FirebaseAuth.instance.currentUser != null;
}

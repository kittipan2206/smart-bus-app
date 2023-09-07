import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:location/location.dart';
// import 'package:get/get.dart';

class AppVariable {
  AppVariable._();

  static Rx<LocationData>? locationData;
  static RxBool isStreamBusLocation = false.obs;
  static RxBool isLogin = false.obs;
  static Rx<User?> user = Rx<User?>(null);
}

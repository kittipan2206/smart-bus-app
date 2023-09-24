import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:smart_bus/firebase_options.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/pages/home/controller/bus_controller.dart';
import 'package:smart_bus/presentation/shared_controller/firebase_services.dart';
// import 'package:smart_bus/presentation/shared_controller/location_controller.dart';

// final getIt = GetIt.instance;

Future<void> setUp() async {
  await getCurrentLocation();
  Get.put(BusController());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseServices.streamBusLocation();
  await FirebaseServices.getBusList();
  isLogin.value = FirebaseAuth.instance.currentUser != null;

  // if (isLogin.value) {
  //     FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser!.uid)
  //         .get()
  //         .then((value) {

  //     });
  //   }
  // getIt
  //   ..registerSingleton(ApiClient())
  //   ..registerSingleton(Database(isar))
  //   ..registerSingleton(UserApi(apiClient: getIt<ApiClient>()))
  //   ..registerSingleton(
  //     UserInformationRepository(
  //       api: getIt<UserApi>(),
  //       database: getIt<Database>(),
  //     ),
  //   );
  // // ..registerSingleton(
  // //   CurrencyRepository(
  // //     api: getIt<CurrencyApi>(),
  // //     database: getIt<Database>(),
  // //   ),
  // // );
}

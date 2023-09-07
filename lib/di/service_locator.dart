import 'package:firebase_core/firebase_core.dart';
import 'package:smart_bus/firebase_options.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/shared_controller/firebase_services.dart';
// import 'package:smart_bus/presentation/shared_controller/location_controller.dart';

// final getIt = GetIt.instance;

Future<void> setUp() async {
  await getCurrentLocation();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseServices.streamBusLocation();
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

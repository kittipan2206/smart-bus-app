import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:smart_bus/di/service_locator.dart';
import 'package:smart_bus/firebase_options.dart';
import 'package:smart_bus/presentation/pages/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_bus/services/notification_services.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // fix only portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "assets/environment.env");
  setUp();
  FlutterNativeSplash.remove();
  final runuableApp = _buildRunnableApp(
    isWeb: kIsWeb,
    webAppWidth: 720,
    app: const App(),
  );
  await NotificationController.initializeLocalNotifications();

  runApp(runuableApp);
}

Widget _buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required Widget app,
}) {
  if (!isWeb) {
    return app;
  }

  return Card(
    child: Center(
      child: ClipRect(
        child: SizedBox(
          width: webAppWidth,
          height: double.infinity,
          child: app,
        ),
      ),
    ),
  );
}

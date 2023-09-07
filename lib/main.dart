import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:smart_bus/di/service_locator.dart';
import 'package:smart_bus/presentation/pages/app/app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await setUp();
  FlutterNativeSplash.remove();
  runApp(const App());
}

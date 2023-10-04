import 'package:flutter/foundation.dart';
import 'package:smart_bus/common/core/languages.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/common/style/app_themes.dart';
import 'package:smart_bus/presentation/pages/core/page_not_found.dart';
import 'package:smart_bus/presentation/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterWebFrame(
      builder: (context) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: Languages(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          theme: AppTheme.lightAppTheme,
          // ios transition
          defaultTransition: Transition.cupertino,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const PageNotFound(),
            transition: Transition.fadeIn,
          ),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
      clipBehavior: Clip.hardEdge,
      maximumSize: const Size(475.0, 812.0),
      enabled: kIsWeb,
      backgroundColor: AppColors.lightBlue,
    );
  }
}

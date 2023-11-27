import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/map_page.dart';
import 'package:smart_bus/presentation/pages/authen/login_page.dart';
import 'package:smart_bus/presentation/pages/home/components/button.dart';
import 'package:smart_bus/presentation/pages/home/components/home_bottom_nav.dart';
import 'package:smart_bus/presentation/pages/home/favorite_page.dart';
import 'package:smart_bus/presentation/pages/home/home_body.dart';
// import 'package:smart_bus/presentation/pages/profile/profile_page.dart';
import 'package:smart_bus/presentation/shared_controller/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/presentation/pages/setting/setting.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    return Container(
      constraints: const BoxConstraints(maxWidth: 414),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: // download apk on web and android
                (kIsWeb)
                    ? CircularIconButton(
                        icon: Icons.download_rounded,
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Download Smart Bus'),
                              content: const Text(
                                  'Download Smart Bus apk to your device to use all features available on only android devices.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    //open url
                                    final uri = Uri.parse(
                                        "https://drive.google.com/file/d/1YZhHHaYKrijJs9XGwlpRjpllfR_sUA9O/view?usp=sharing");
                                    // if (await canLaunchUrl(uri)) {
                                    try {
                                      await launchUrl(uri);
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                          msg: "Can't launch url $e",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }

                                    // } else {
                                    //   // can't launch url
                                    // }
                                  },
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : null,
            title: const Text('Smart Bus'),
            actions: [
              Obx(() => isLogin.value
                  ? CircularIconButton(
                      icon: Icons.favorite,
                      onPressed: () {
                        Get.to(() => const FavoritePage());
                      },
                    )
                  : CircularIconButton(
                      icon: Icons.login_rounded,
                      onPressed: () {
                        Get.to(() => const LoginPage());
                      },
                    )),
            ],
          ),
          bottomNavigationBar: const HomeBottomNav(),
          body: Obx(
            () => IndexedStack(
              index: homeController.tabIndex.value,
              children: const [
                HomeBody(),
                MapScreen(),
                SettingPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

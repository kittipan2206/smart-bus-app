import 'package:smart_bus/globals.dart';
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
                SettingPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

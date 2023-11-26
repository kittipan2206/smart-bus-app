import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/presentation/shared_controller/home/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  static Obx buildBottomNavigationMenu(context, homeController) {
    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        iconSize: 30,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        onTap: homeController.changeTabIndex,
        currentIndex: homeController.tabIndex.value,
        unselectedItemColor: AppColors.lightBlue,
        selectedItemColor: AppColors.blue,
        // backgroundColor: AppColors.deepBLue,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              CupertinoIcons.house,
            ),
            activeIcon: const Icon(
              CupertinoIcons.house_fill,
            ),
            label: 'Home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              CupertinoIcons.map,
            ),
            activeIcon: const Icon(
              CupertinoIcons.map_fill,
            ),
            label: 'Map'.tr,
          ),
          BottomNavigationBarItem(
            // SOS icon
            icon: const Icon(
              CupertinoIcons.settings,
            ),
            label: 'Settings'.tr,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBottomNavigationMenu(context, Get.find<HomeController>());
  }
}

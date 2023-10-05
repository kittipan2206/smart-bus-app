import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool isGoogleDistanceMatrixAPI = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          tileColor: AppColors.yellow,
          // textColor: AppColors.white,
          contentPadding: const EdgeInsets.all(10),
          title: const Text('Google Distance Matrix API'),
          subtitle: const Text(
              'Open Google Distance Matrix API for get distance and duration of bus'),
          trailing: FutureBuilder<bool?>(
              future: prefs
                  .then((value) => value.getBool('googleDistanceMatrixAPI')),
              builder: (context, snapshot) {
                return Switch(
                  value: snapshot.data ?? false,
                  onChanged: (bool value) {
                    setState(() {});
                  },
                );
              }),
        ),
        // logout button
        Obx(() {
          if (isLogin.value) {
            return ListTile(
              leading: const Icon(Icons.logout),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              tileColor: AppColors.red.withOpacity(0.2),
              // textColor: AppColors.white,
              contentPadding: const EdgeInsets.all(10),
              title: const Text('Logout'),
              subtitle: const Text('Logout from this account'),
              onTap: () async {
                // firebaseAuth.signOut();
                Get.dialog(AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure to logout?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () async {
                          FirebaseAuth.instance.signOut();
                          isLogin.value = false;
                          Fluttertoast.showToast(msg: 'Logout success!');
                          Get.back();
                        },
                        child: const Text('Logout',
                            style: TextStyle(color: Colors.red))),
                  ],
                ));
              },
            );
          }
          return const SizedBox();
        }),
        // show version
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                      style: const TextStyle(color: Colors.grey),
                    );
                  }
                  return const SizedBox();
                }),
          ],
        )
      ],
    ));
  }
}

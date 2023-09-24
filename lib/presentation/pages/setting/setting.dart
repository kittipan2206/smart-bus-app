import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/pages/app/app.dart';

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
    getPrefs();
  }

  bool isGoogleDistanceMatrixAPI = false;
  getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isGoogleDistanceMatrixAPI =
        prefs.getBool('googleDistanceMatrixAPI');
    print(isGoogleDistanceMatrixAPI);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Setting'),
        ),
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
                  future: prefs.then(
                      (value) => value.getBool('googleDistanceMatrixAPI')),
                  builder: (context, snapshot) {
                    return Switch(
                      value: snapshot.data ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          isGoogleDistanceMatrixAPI = value;
                          prefs.then((value) => value.setBool(
                              'googleDistanceMatrixAPI',
                              isGoogleDistanceMatrixAPI));
                          Future<bool?> test = prefs.then((value) =>
                              value.getBool('googleDistanceMatrixAPI'));
                          test.then((value) => print(value));
                        });
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
                  tileColor: AppColors.yellow,
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
                            },
                            child: const Text('Logout',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ));
                  },
                );
              }
              return const SizedBox();
            })
          ],
        ));
  }
}

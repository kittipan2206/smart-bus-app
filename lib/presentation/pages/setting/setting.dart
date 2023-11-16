import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_bus/presentation/pages/authen/register_page.dart';

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
        Obx(() {
          print(userInfo['roles']);
          if (userInfo['roles'] == "driver" && isLogin.value) {
            return ExpansionTile(
              title: const Text('Bus'),
              leading: const Icon(Icons.bus_alert_sharp),
              subtitle: const Text('Manage your bus'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: AppColors.yellow,
              children: [
                // loop bus list
                Obx(() {
                  final driverBus = busList.where((element) {
                    return element.ownerId == user.value!.uid;
                  }).toList();
                  if (driverBus.isNotEmpty) {
                    return Card(
                      // padding: const EdgeInsets.symmetric(horizontal: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: driverBus.length + 1,
                          itemBuilder: (context, index) {
                            if (index == driverBus.length) {
                              return ListTile(
                                leading: const Icon(Icons.add),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                // textColor: AppColors.white,
                                contentPadding: const EdgeInsets.all(10),
                                title: const Text('Add bus'),
                                subtitle: const Text('Add new bus'),
                                onTap: () {
                                  addBusDialog(rawBusList: driverBus);
                                },
                              );
                            }
                            return ListTile(
                              leading: const Icon(Icons.bus_alert),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(driverBus[index].name ?? ''),
                              subtitle: Text(driverBus[index].licensePlate ??
                                  'No license plate'),
                              onTap: () {
                                addBusDialog(
                                    rawBusList: driverBus,
                                    bus: driverBus[index]);
                              },
                              trailing: IconButton(
                                  onPressed: () async {
                                    Get.dialog(AlertDialog(
                                      title: const Text('Delete bus'),
                                      content: Text(
                                          'Are you sure to delete ${driverBus[index].name} bus?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () async {
                                              print(driverBus[index].id);
                                              await FirebaseFirestore.instance
                                                  .collection('bus_data')
                                                  .doc(driverBus[index].id)
                                                  .delete();
                                              Fluttertoast.showToast(
                                                  msg: 'Delete bus success!');
                                              Get.back();
                                            },
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red))),
                                      ],
                                    ));
                                  },
                                  icon: const Icon(Icons.delete)),
                            );
                          }),
                    );
                  }
                  return const Text('No buses found');
                }),
              ],
            );
            // return addBus(driverBusList);
          }
          return const SizedBox();
        }),
        // logout button
        Obx(() {
          if (isLogin.value) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
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
                child: const Text('Logout'),
              ),
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

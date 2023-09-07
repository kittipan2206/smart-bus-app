import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/common/style/app_colors.dart';
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
        body: ListTile(
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
                    setState(() {
                      isGoogleDistanceMatrixAPI = value;
                      prefs.then((value) => value.setBool(
                          'googleDistanceMatrixAPI',
                          isGoogleDistanceMatrixAPI));
                      Future<bool?> test = prefs.then(
                          (value) => value.getBool('googleDistanceMatrixAPI'));
                      test.then((value) => print(value));
                    });
                  },
                );
              }),
        ));
  }
}

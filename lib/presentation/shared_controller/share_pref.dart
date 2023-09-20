import 'package:shared_preferences/shared_preferences.dart';

class SharePrefs {
  static saveFavorite(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
}

// ignore: prefer_single_quotes
import "package:get/get.dart";
import 'package:location/location.dart';

class HomeController extends GetxController {
  final RxInt tabIndex = 0.obs;
  Rx<LocationData> locationData = LocationData.fromMap({}).obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}

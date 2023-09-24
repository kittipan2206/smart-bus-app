import 'package:get/get.dart';
import 'package:smart_bus/model/bus_stop_model.dart';

class BusController extends GetxController {
  Rx<BusStopModel>? busModel;
  RxList busLineList = [].obs;


}

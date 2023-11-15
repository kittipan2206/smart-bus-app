import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/presentation/pages/shared_components/dialog_manager.dart';
import 'package:smart_bus/services/firebase_services.dart';

import 'model/bus_stop_model.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger();
Rx<int> selectedBusStopIndex = (-1).obs;
SharedPreferences? prefs;
Rx<bool> isLogin = false.obs;
RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
bool getGoogleApi = false;
String profile = 'foot-walking';
Rx<User?> user = FirebaseAuth.instance.currentUser.obs;
StreamController<BusStopModel> busStreamController =
    StreamController<BusStopModel>();
RxList<BusStopModel> busStopList = <BusStopModel>[].obs;
Location currentLocation = Location();
BusStopModel? nearestBusStop;
Rx<bool> isStreamBusLocation = false.obs;
Rx<BusModel?> selectedBusSharingId = Rx<BusModel?>(null);
const distanceInMetersThreshold = 100;
RxList<BusModel> busList = <BusModel>[].obs;
RxList<BusModel> driverBusList = <BusModel>[].obs;
late LocationData _locationData;
Rx<LatLng> userLatLng = const LatLng(0, 0).obs;
Future<void> getCurrentLocation() async {
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  prefs = await SharedPreferences.getInstance();

  // getGoogleApi = prefs!.getBool('googleDistanceMatrixAPI') ?? false;
  try {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // show toast
        Fluttertoast.showToast(msg: 'Please enable location service');
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // show toast
        Fluttertoast.showToast(msg: 'Please enable location permission');
        return;
      }
    }
    // filter location
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 3000, distanceFilter: 1);

    // get first location
    _locationData = await location.getLocation();
    userLatLng.value =
        LatLng(_locationData.latitude!, _locationData.longitude!);
    logger.i(
        'location changed ${_locationData.latitude} - ${_locationData.longitude}');

    location.onLocationChanged.listen((LocationData currentLocation) {
      // Use current location
      logger.i(
          'location changed ${currentLocation.latitude} - ${currentLocation.longitude}');
      _locationData = currentLocation;
      userLatLng.value =
          LatLng(_locationData.latitude!, _locationData.longitude!);
      if (isStreamBusLocation.value) {
        FirebaseServices.updateFirebaseBusLocation(user.value!.uid);
        checkIsNearBusStop(distanceInMetersThreshold);
      }
    });
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error: $e');
  }
}

void checkIsNearBusStop(threshold) {
  final busStopInLine = busStopList
      .where((element) => element.line['line']
          .contains(selectedBusSharingId.value!.busStopLine))
      .toList();
  logger.i('busStopInLine: $busStopInLine');
  if (busStopList.isNotEmpty) {
    const distance = latLng.Distance();
    for (var element in busStopInLine) {
      double meter = distance.as(
        latLng.LengthUnit.Meter,
        latLng.LatLng(element.location.latitude, element.location.longitude),
        latLng.LatLng(userLatLng.value.latitude, userLatLng.value.longitude),
      );

      if (meter < threshold) {
        logger.i('nearest bus stop: ${element.name}');
        showSelectedBusStop(element);
      }
    }
  }
}

void showSelectedBusStop(BusStopModel busStop) {
  DialogManager().showSelectNextBusStopDialog(busStop: busStop, alert: true);
}

Future<void> getBusList() async {
  isLogin.value
      ? await FirebaseFirestore.instance
          .collection('bus_data')
          .where('owner', isEqualTo: user.value!.uid)
          .get()
          .then(
          (value) async {
            logger.i(value.docs.length);
            for (var element in value.docs) {
              await FirebaseFirestore.instance
                  .collection('bus_data')
                  .doc(element.id)
                  .get()
                  .then((value) async {
                busList.add(BusModel.fromJson(value.data()!));
                logger.i('allBusList: $busList');
              });
            }
          },
        )
      : await FirebaseFirestore.instance.collection('bus_data').get().then(
          (value) async {
            for (var element in value.docs) {
              FirebaseFirestore.instance
                  .collection('bus_data')
                  .doc(element.id)
                  .snapshots()
                  .listen((event) async {
                busList.add(BusModel.fromJson(event.data()!));

                logger.i('allBusList: $busList');
              });
            }
          },
        );
}

Future<dynamic> getDistance({required LatLng busLatLng}) async {
  String url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${userLatLng.value.latitude},${userLatLng.value.longitude}&origins=${busLatLng.latitude},${busLatLng.longitude}&key=AIzaSyCaGjSBHkRCXtTB8u0H9yeErCPg6xDVLD8';
  try {
    logger.i("user lat long api get$userLatLng");
    var response = await http.get(
        Uri.parse(
          url,
        ),
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*'
        });
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  } catch (e) {
    logger.i(e);
    return null;
  }
}

Future<void> getDistanceDuration() async {
  logger.i('get this api$userLatLng');
  String url = 'https://api.openrouteservice.org/v2/matrix/$profile';

  Map<String, dynamic> jsonPayload = {
    "locations": [
      [userLatLng.value.longitude, userLatLng.value.latitude],
      ...busStopList.map((e) => [e.location.longitude, e.location.latitude])
    ],
    "metrics": ["distance", "duration"],
    "resolve_locations": "true",
    "sources": [0]
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Accept":
            "application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8",
        "Authorization": dotenv.env['OPEN_ROUTE_SERVICE_API_KEY']!,
      },
      body: json.encode(jsonPayload),
    );
    if (response.statusCode == 200) {
      var output = json.decode(response.body);
      for (int i = 0; i < busStopList.length; i++) {
        // duration unit is second
        int rawDuration = output['durations'][0][i + 1].toInt() + 1;
        busStopList[i].durationInSeconds = rawDuration;
        // distance unit is meter
        int rawDistance = output['distances'][0][i + 1].toInt() + 1;
        busStopList[i].distanceInMeters = rawDistance;
        busStopList[i].address =
            output['destinations'][i + 1]['name'] ?? 'unknown';
      }
      busStopList
          .sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
      busStreamController.add(busStopList.first);
    } else {
      Fluttertoast.showToast(msg: 'Error: ${response.statusCode}');
    }
  } catch (e) {
    logger.i(e);
  }
}

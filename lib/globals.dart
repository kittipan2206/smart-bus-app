import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/model/bus_model.dart';

import 'model/bus_stop_model.dart';
import 'package:http/http.dart' as http;

Rx<int> selectedBusStopIndex = (-1).obs;
SharedPreferences? prefs;
bool isLogin = false;
bool getGoogleApi = false;
String profile = 'foot-walking';
User? user;
StreamController<BusStopModel> busStreamController =
    StreamController<BusStopModel>();
RxList<BusStopModel> busStopList = <BusStopModel>[].obs;
Location currentLocation = Location();
BusStopModel? nearestBusStop;
bool isStreamBusLocation = false;
String? busDriverUID;

RxList<BusModel> busList = <BusModel>[].obs;

late LocationData _locationData;
LatLng? userLatLng;
getCurrentLocation() async {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  prefs = await SharedPreferences.getInstance();

  getGoogleApi = prefs!.getBool('googleDistanceMatrixAPI') ?? false;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
  // filter location
  location.changeSettings(
      accuracy: LocationAccuracy.high, interval: 3000, distanceFilter: 1);

  // get first location
  _locationData = await location.getLocation();
  userLatLng = LatLng(_locationData.latitude!, _locationData.longitude!);

  location.onLocationChanged.listen((LocationData currentLocation) {
    // Use current location
    _locationData = currentLocation;
    userLatLng = LatLng(_locationData.latitude!, _locationData.longitude!);
    if (isStreamBusLocation) {
      updateFirebaseBusLocation();
    }
  });
}

updateFirebaseBusLocation() async {
  // update bus location where field owner is busDriverUID
  await FirebaseFirestore.instance
      .collection('bus_data')
      .where('owner', isEqualTo: busDriverUID)
      .get()
      .then((value) async {
    print(value.docs.length);
    for (var element in value.docs) {
      await FirebaseFirestore.instance
          .collection('bus_data')
          .doc(element.id)
          .update({
        'location': GeoPoint(_locationData.latitude!, _locationData.longitude!)
      });
    }
  });
}

Future<void> getBusList() async {
  isLogin
      ? await FirebaseFirestore.instance
          .collection('bus_data')
          .where('owner', isEqualTo: busDriverUID)
          .get()
          .then(
          (value) async {
            print(value.docs.length);
            for (var element in value.docs) {
              await FirebaseFirestore.instance
                  .collection('bus_data')
                  .doc(element.id)
                  .get()
                  .then((value) async {
                busList.add(BusModel.fromJson(value.data()!));
                print('allBusList: ${busList}');
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

                print('allBusList: ${busList}');
              });
            }
          },
        );
}

Future<dynamic> getDistance({required LatLng busLatLng}) async {
  String url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${userLatLng!.latitude},${userLatLng!.longitude}&origins=${busLatLng.latitude},${busLatLng.longitude}&key=AIzaSyCaGjSBHkRCXtTB8u0H9yeErCPg6xDVLD8';
  try {
    print("user lat long api get" + userLatLng.toString());
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
    } else
      return null;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<void> getDistanceDuration() async {
  print('get api $userLatLng');
  String url = 'https://api.openrouteservice.org/v2/matrix/$profile';

  Map<String, dynamic> jsonPayload = {
    "locations": [
      [userLatLng!.longitude, userLatLng!.latitude],
      ...busStopList.map((e) => [e.location.longitude, e.location.latitude])
    ],
    "metrics": ["distance", "duration"],
    "resolve_locations": "true",
    "sources": [0]
  };

  try {
    print(jsonPayload);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Accept":
            "application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8",
        "Authorization":
            "5b3ce3597851110001cf62482c216c56fdbe49f5a15841ad3a59b770"
      },
      body: json.encode(jsonPayload),
    );
    if (response.statusCode == 200) {
      var output = json.decode(response.body);
      print(output);
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
      print(response.statusCode);
      print(response.body);
    }
  } catch (e) {
    print(e);
  }
}

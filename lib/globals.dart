import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/bus_model.dart';
import 'package:http/http.dart' as http;

int? selectedBusIndex;
SharedPreferences? prefs;
bool isLogin = false;
bool getGoogleApi = false;
String profile = 'foot-walking';
User? user;
// stream bus location
StreamController<BusModel> busStreamController = StreamController<BusModel>();
// StreamController<bool> allBusStreamController = StreamController<bool>();
// bus list
Rx<List<BusModel>> busList = Rx<List<BusModel>>([]);
Location currentLocation = Location();
BusModel? nearestBusStop;
bool isStreamBusLocation = false;
String? busDriverUID;

var allBusList = [];

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

// // stream bus location from firebase
// Future<void> streamBusLocation() async {
//   print('streamBusLocation');
//   await FirebaseFirestore.instance
//       .collection('bus_stop_data')
//       .get()
//       .then((value) async {
//     for (var element in value.docs) {
//       FirebaseFirestore.instance
//           .collection('bus_stop_data')
//           .doc(element.id)
//           .snapshots()
//           .listen((event) async {
//         GeoPoint geoPoint = event['location'];
//         print('${element.id} ${geoPoint.latitude}, ${geoPoint.longitude}');
//         // update bus location
//         final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
//         dynamic gDistanceApi = {
//           'rows': [
//             {
//               'elements': [
//                 {
//                   'status': 'N/A',
//                   'distance': {'text': 'N/A', 'value': 0},
//                   'duration': {'text': 'N/A', 'value': 0}
//                 }
//               ]
//             }
//           ],
//           'origin_addresses': ['N/A']
//         };

//         try {
//           String distance = 'Not available';
//           String duration = 'Not available';
//           int distanceValue = 0;
//           String originAddress = 'Not available';
//           int durationValue = 0;
//           print(getGoogleApi);
//           if (getGoogleApi) {
//             dynamic gDistanceApi = await getDistance(busLatLng: latLng);
//             print(gDistanceApi);
//             if (gDistanceApi['rows'][0]['elements'][0]['status'] == 'OK' &&
//                 getGoogleApi == true) {
//               distance =
//                   gDistanceApi['rows'][0]['elements'][0]['distance']['text'];
//               duration =
//                   gDistanceApi['rows'][0]['elements'][0]['duration']['text'];
//               distanceValue =
//                   gDistanceApi['rows'][0]['elements'][0]['distance']['value'];
//               originAddress = gDistanceApi['origin_addresses'][0].toString();
//               durationValue =
//                   gDistanceApi['rows'][0]['elements'][0]['duration']['value'];
//             }
//           }

//           print('distance: $distance');
//           print('duration: $duration');
//           // busList.add(Bus(
//           //   id: element.id,
//           //   name: element['name'],
//           //   location: geoPoint,
//           //   distance: distance,
//           //   duration: duration,
//           // ));
//           // print('list' + busList.length.toString());
//           // sort bus list by distance
//           busList.value
//               .sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

//           busList.value.removeWhere((element) => element.id == event.id);
//           busList.value.add(BusModel(
//             id: event.id,
//             name: event['name'],
//             location: geoPoint,
//             // distance: distance,
//             // duration: duration,
//             distanceInMeters: distanceValue,
//             address: originAddress,
//             durationInSeconds: durationValue,
//             line: event['line'],
//           ));
//           print('list' + busList.value.length.toString());
//         } catch (e) {
//           // Fluttertoast.showToast(msg: 'Error: $e');
//           print(e);
//         }
//       });

//       // addBusMarker(element.id, LatLng(geoPoint.latitude, geoPoint.longitude));
//       // when complete sort bus list
//     }
//     await Future.delayed(const Duration(seconds: 1));
//     await getDistanceDuration();
//     for (var i = 0; i < busList.value.length; i++) {
//       print('busList: ${busList.value[i].name}');
//       print('busList: ${busList.value[i].getDistance()}');
//       print('busList: ${busList.value[i].getDuration()}');
//       busList.value[i].startTimer();
//     }
//   });
// }

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
                allBusList.add(value.data()!);
                print('allBusList: ${allBusList}');
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
                allBusList.add(event.data()!);

                print('allBusList: ${allBusList}');
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
      ...busList.value.map((e) => [e.location.longitude, e.location.latitude])
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
      for (int i = 0; i < busList.value.length; i++) {
        // duration unit is second
        int rawDuration = output['durations'][0][i + 1].toInt() + 1;
        busList.value[i].durationInSeconds = rawDuration;
        // distance unit is meter
        int rawDistance = output['distances'][0][i + 1].toInt() + 1;
        busList.value[i].distanceInMeters = rawDistance;
        busList.value[i].address =
            output['destinations'][i + 1]['name'] ?? 'unknown';
      }
      busList.value
          .sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
      busStreamController.add(busList.value.first);
    } else {
      print(response.statusCode);
      print(response.body);
    }
  } catch (e) {
    print(e);
  }
}

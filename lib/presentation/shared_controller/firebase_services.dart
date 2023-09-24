import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_bus/common/core/app_variables.dart';
import 'package:smart_bus/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/controller/bus_controller.dart';

class FirebaseServices {
  // get bus controller
  static BusController busController = Get.find<BusController>();
  static void updateFirebaseBusLocation(busDriverUID) async {
    // update bus location where field owner is busDriverUID
    await FirebaseFirestore.instance
        .collection('bus_data')
        .where('owner', isEqualTo: busDriverUID)
        .get()
        .then((value) async {
      print(value.docs.length);
      for (final element in value.docs) {
        await FirebaseFirestore.instance
            .collection('bus_data')
            .doc(element.id)
            .update({
          'location': GeoPoint(AppVariable.locationData!.value.latitude!,
              AppVariable.locationData!.value.longitude!)
        });
      }
    });
  }

  static Future<void> getBusList() async {
    isLogin.value
        ? await FirebaseFirestore.instance
            .collection('bus_data')
            .where('owner', isEqualTo: user.value!.uid)
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
                  // remove old bus
                  busList.removeWhere((element) => element.id == value.id);
                  busList.add(BusModel.fromJson(value.data()!));
                  print('allBusList: ${busList.toString()}');
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
                  // remove old bus
                  busList.removeWhere((element) => element.id == event.id);
                  busList.add(BusModel.fromJson(event.data()!));

                  print('allBusList: ${busList}');
                });
              }
            },
          );
  }

  static Future<void> streamBusLocation() async {
    print('streamBusLocation');
    getBusLine();
    await FirebaseFirestore.instance
        .collection('bus_stop_data')
        .get()
        .then((value) async {
      for (var element in value.docs) {
        FirebaseFirestore.instance
            .collection('bus_stop_data')
            .doc(element.id)
            .snapshots()
            .listen((event) async {
          GeoPoint geoPoint = event['location'];
          print('${element.id} ${geoPoint.latitude}, ${geoPoint.longitude}');
          // update bus location
          final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

          try {
            String distance = 'Not available';
            String duration = 'Not available';
            int distanceValue = 0;
            String originAddress = 'Not available';
            int durationValue = 0;
            if (getGoogleApi) {
              dynamic gDistanceApi = await getDistance(busLatLng: latLng);
              if (gDistanceApi['rows'][0]['elements'][0]['status'] == 'OK' &&
                  getGoogleApi == true) {
                distance =
                    gDistanceApi['rows'][0]['elements'][0]['distance']['text'];
                duration =
                    gDistanceApi['rows'][0]['elements'][0]['duration']['text'];
                distanceValue =
                    gDistanceApi['rows'][0]['elements'][0]['distance']['value'];
                originAddress = gDistanceApi['origin_addresses'][0].toString();
                durationValue =
                    gDistanceApi['rows'][0]['elements'][0]['duration']['value'];
              }
            }

            print('distance: $distance');
            print('duration: $duration');

            busStopList.removeWhere((element) => element.id == event.id);
            busStopList.add(BusStopModel(
              id: event.id,
              name: event['name'],
              location: geoPoint,
              distanceInMeters: distanceValue,
              address: originAddress,
              durationInSeconds: durationValue,
              line: event['line'],
            ));
            // for loop to get bus line
            // for (var i = 0; i < busStopList.length; i++) {
            //   for (var j = 0; j < busStopList[i].line['line'].length; j++) {
            //     if (busController.busLineList
            //         .contains(busStopList[i].line['line'][j])) {
            //       continue;
            //     }
            //     busController.busLineList.add(busStopList[i].line['line'][j]);
            //   }
            // }

            // busList.value.sort(
            //     (a, b) => a.line['order'][0].compareTo(b.line['order'][0]));
            // print('list' + busList.value.length.toString());
          } catch (e) {
            // Fluttertoast.showToast(msg: 'Error: $e');
            print(e);
          }
        });

        // addBusMarker(element.id, LatLng(geoPoint.latitude, geoPoint.longitude));
        // when complete sort bus list
      }
      await Future.delayed(const Duration(seconds: 1));
      await getDistanceDuration();
      for (var i = 0; i < busStopList.length; i++) {
        // print('busList.value: ${busList.value[i].name}');
        // print('busList.value: ${busList.value[i].getDistance()}');
        // print('busList.value: ${busList.value[i].getDuration()}');
        busStopList[i].startTimer();
      }
    });
  }

  static Future<void> getBusLine() async {
    FirebaseFirestore.instance.collection('bus_line').get().then((value) async {
      for (var element in value.docs) {
        FirebaseFirestore.instance
            .collection('bus_line')
            .doc(element.id)
            .snapshots()
            .listen((event) {
          // remove old bus
          print(event.id);
          busController.busLineList
              .removeWhere((element) => element["Id"] == event.data()!["Id"]);
          busController.busLineList.add(event.data());
          print('busLineList: ${busController.busLineList}');
        });
      }
    });
  }

  static Future<void> checkLogin() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) async {
      FirebaseAuth auth = FirebaseAuth.instance;
      AppVariable.isLogin.value = auth.currentUser != null;
      if (auth.currentUser != null) {
        AppVariable.user.value = auth.currentUser;
        // allBusList.clear();
        // await getBusList();
        // busDriverUID = user!.uid;
        print(auth.currentUser.runtimeType);
        print('auth.currentUser: ${auth.currentUser?.email}');
        print('auth.currentUser: ${auth.currentUser?.displayName}');
        return;
      }
      // if (type == null) return;
      print('isLogin: ${AppVariable.isLogin.value}');
      // setState(() {
      //   text = 'Fetching bus list...';
      // });
      // await streamBusLocation();
      // await getBusList();
      unawaited(Fluttertoast.showToast(msg: 'Firebase initialized'));
    });
  }
}

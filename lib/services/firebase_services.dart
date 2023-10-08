import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        .where('documentId', isEqualTo: selectedBusSharingId.value!.id)
        .get()
        .then((value) async {
      logger.i(value.docs.length);
      for (final element in value.docs) {
        await FirebaseFirestore.instance
            .collection('bus_data')
            .doc(element.id)
            .update({
          'location': GeoPoint(userLatLng.value.latitude,
              userLatLng.value.longitude), // update bus location
        });
      }
    });
  }

  static Future<void> getBusList() async {
    // listen to bus data
    FirebaseFirestore.instance.collection('bus_data').snapshots().listen(
      (value) async {
        busList.clear();
        for (var element in value.docs) {
          FirebaseFirestore.instance
              .collection('bus_data')
              .doc(element.id)
              .snapshots()
              .listen((event) async {
            // remove old bus
            busList.removeWhere((element) => element.id == event.id);
            busList.add(BusModel.fromJson(event.data()!));
            logger.i('allBusList: $busList');
          });
        }
      },
    );
  }

  static Future<void> getDriverBusList() async {
    await FirebaseFirestore.instance
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
            // remove old bus
            driverBusList.removeWhere((element) => element.id == value.id);
            driverBusList.add(BusModel.fromJson(value.data()!));
            logger.i('driverbus: ${driverBusList.toString()}');
          });
        }
      },
    );
  }

  static Future<void> streamBusLocation() async {
    logger.i('streamBusLocation');
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
          logger.i('${element.id} ${geoPoint.latitude}, ${geoPoint.longitude}');
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

            logger.i('distance: $distance');
            logger.i('duration: $duration');

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
          } catch (e) {
            // Fluttertoast.showToast(msg: 'Error: $e');
            logger.i(e);
          }
        });

        // addBusMarker(element.id, LatLng(geoPoint.latitude, geoPoint.longitude));
        // when complete sort bus list
      }
      await Future.delayed(const Duration(seconds: 1));
      await getDistanceDuration();
      for (var i = 0; i < busStopList.length; i++) {
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
          logger.i(event.id);
          busController.busLineList
              .removeWhere((element) => element["Id"] == event.data()!["Id"]);
          busController.busLineList.add(event.data());
          logger.i('busLineList: ${busController.busLineList}');
        });
      }
    });
  }

  static Future loginWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication? userAuth = await googleUser?.authentication;
      final auth = FirebaseAuth.instance;

      await auth.signInWithCredential(GoogleAuthProvider.credential(
          idToken: userAuth!.idToken, accessToken: userAuth.accessToken));
      Fluttertoast.showToast(msg: 'Login success');
      user.value = auth.currentUser;
      // if dost not have user info
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.value!.uid)
          .get()
          .then((value) async {
        if (!value.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.value!.uid)
              .set({
            'roles': 'user',
          });
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.value!.uid)
              .snapshots()
              .listen((event) {
            userInfo.value = event.data()!;
          });
        } else {
          // listen to user info
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.value!.uid)
              .snapshots()
              .listen((event) {
            userInfo.value = event.data()!;
          });
        }
      });

      isLogin.value = true;
      Get.back();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Login failed $e');
      logger.i(e);
    }
  }
}
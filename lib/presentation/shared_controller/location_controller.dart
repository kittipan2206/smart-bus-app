import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_bus/common/core/app_variables.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/shared_controller/firebase_services.dart';
import 'package:location/location.dart';

class LocationServices {
  static Future<void> initialize() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // filter location
    await location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 3000, distanceFilter: 1);

    // get first location
    // AppVariable.locationData!.value = await location.getLocation();

    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude == null ||
          currentLocation.longitude == null) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: const Text('Cannot get location'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('OK'),
            )
          ],
        ));
      }
      userLatLng.value =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
      print(
          'location changed ${currentLocation.latitude} - ${currentLocation.longitude}');
      // Use current location
      // AppVariable.locationData.value = currentLocation;
      // print('location changed');
      if (AppVariable.isStreamBusLocation.value) {
        FirebaseServices.updateFirebaseBusLocation('busDriverUID');
      }
    });
  }
}

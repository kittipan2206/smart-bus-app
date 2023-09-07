import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_bus/globals.dart';

class BusModel {
  // don't use same id for two buses
  String id;
  String name;
  GeoPoint location;
  // bool status = false;
  int distanceInMeters;
  String address;
  int durationInSeconds;
  var line;

  BusModel({
    required this.id,
    required this.name,
    required this.location,
    status,
    // required this.distance,
    // required this.duration,
    required this.distanceInMeters,
    required this.address,
    required this.durationInSeconds,
    required this.line,
  });

  // count down timer
  void startTimer() {
    Timer? timer;

    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) => {
        if (durationInSeconds > 0)
          {
            durationInSeconds = durationInSeconds - 1,
          }
        else
          {timer.cancel(), getDistanceDuration()}
      },
    );
  }

  // convert distance in meters to distance string
  String getDistance() {
    if (distanceInMeters < 1000) {
      return '$distanceInMeters m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // convert duration in seconds to duration string
  String getDuration() {
    if (durationInSeconds < 60) {
      return '$durationInSeconds s';
    } else if (durationInSeconds < 3600) {
      return '${(durationInSeconds / 60).toStringAsFixed(0)} min';
    } else {
      return '${(durationInSeconds / 3600).toStringAsFixed(0)} hours';
    }
  }
}

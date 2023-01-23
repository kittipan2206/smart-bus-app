import 'package:cloud_firestore/cloud_firestore.dart';

class Bus {
  // don't use same id for two buses
  String id;
  String name;
  GeoPoint location;
  bool status = false;
  String distance;
  String duration;
  int distanceInMeters;
  String address;

  Bus(
      {required this.id,
      required this.name,
      required this.location,
      status,
      required this.distance,
      required this.duration,
      required this.distanceInMeters,
      required this.address});
}

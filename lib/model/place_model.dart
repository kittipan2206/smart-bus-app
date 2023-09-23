import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_bus/model/bus_stop_model.dart';

class PlaceModel {
  final String name;
  final String address;
  final GeoPoint location;
  Map<BusStopModel, int> adjacentStops = {};

  PlaceModel({
    required this.name,
    required this.address,
    required this.location,
    this.adjacentStops = const {},
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: json['name'],
      address: json['address'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'location': location,
      };

  @override
  String toString() {
    return 'PlaceModel{name: $name, address: $address, location: $location}';
  }

  // add adjacent stops to the map
  void addAdjacentStops(BusStopModel busStop, int distance) {
    adjacentStops[busStop] = distance;
  }
}

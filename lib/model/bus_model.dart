import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  String id;
  String? name;
  String? licensePlate;
  dynamic busStopLine;
  GeoPoint? location;
  String? owner;
  bool? status;
  String? nextBusStop;
  bool? onward;
  Map? matrix;

  BusModel({
    required this.id,
    this.name,
    this.licensePlate,
    this.busStopLine,
    this.location,
    this.owner,
    this.status,
    this.nextBusStop,
    this.onward,
    this.matrix,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['documentId'],
      name: json['name'],
      licensePlate: json['LP'],
      busStopLine: json['bus_stop_line'],
      location: json['location'],
      owner: json['owner'],
      status: json['status'],
      nextBusStop: json['nextBusStop'],
      onward: json['onward'],
      matrix: json['matrix'],
    );
  }

  Map<String, dynamic> toJson() => {
        'documentId': id,
        'name': name,
        'LP': licensePlate,
        'busStopLine': busStopLine,
        'location': location,
        'owner': owner,
        'status': status,
        'nextBusStop': nextBusStop,
        'onward': onward,
        'matrix': matrix,
      };

  @override
  String toString() {
    return 'BusModel{id: $id, name: $name, licensePlate: $licensePlate, busStopLine: $busStopLine, location: $location, owner: $owner, status: $status, nextBusStop: $nextBusStop, onward: $onward, matrix: $matrix}';
  }
}

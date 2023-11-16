import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_bus/model/bus_stop_model.dart';

class HistoryModel {
  BusStopModel busStop;
  Timestamp time;

  HistoryModel({
    required this.busStop,
    required this.time,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      busStop: BusStopModel.fromJson(json['busStop']),
      // timestamp to DateTime
      time: json['time'],
    );
  }
}

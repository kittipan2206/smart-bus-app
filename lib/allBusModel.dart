// {onward: true, LP: กข 1234, nextBusStop: SalJaoJuiTui, name: bus01, location: Instance of 'GeoPoint', documentId: 5NRdlgPGGKPbRQMNJTLi, matrix: {duration: [272.84, 300.7, 94.55, 33.93, 145.94, 245.37, 195.16, 404.5, 312.43], distance: [3845.8, 3744.9, 1052.67, 254, 1915.08, 2152.92, 1883.07, 3584.76, 3354.95]}
import 'package:cloud_firestore/cloud_firestore.dart';

class AllBus {
  String id;
  String name;
  GeoPoint location;
  String onward;
  String LP;
  String nextBusStop;
  String documentId;
  Map<String, dynamic> matrix;

  AllBus({
    required this.id,
    required this.name,
    required this.location,
    required this.onward,
    required this.LP,
    required this.nextBusStop,
    required this.documentId,
    required this.matrix,
  });

  factory AllBus.fromDocument(DocumentSnapshot doc) {
    return AllBus(
      id: doc['id'],
      name: doc['name'],
      location: doc['location'],
      onward: doc['onward'],
      LP: doc['LP'],
      nextBusStop: doc['nextBusStop'],
      documentId: doc.id,
      matrix: doc['matrix'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'onward': onward,
      'LP': LP,
      'nextBusStop': nextBusStop,
      'documentId': documentId,
      'matrix': matrix,
    };
  }

  @override
  String toString() {
    return 'allBus{id: $id, name: $name, location: $location, onward: $onward, LP: $LP, nextBusStop: $nextBusStop, documentId: $documentId, matrix: $matrix}';
  }
}

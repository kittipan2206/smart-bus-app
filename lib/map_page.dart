import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/presentation/pages/home/bus_detail_page.dart';
import 'package:smart_bus/services/firebase_services.dart';

class MapScreen extends StatefulWidget {
  static const id = "HOME_SCREEN";

  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final List<Marker> _markers = <Marker>[];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final _mapMarkerSC = StreamController<List<Marker>>();

  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  @override
  void initState() {
    super.initState();
    FirebaseServices.getStreamBusData().listen((busData) {
      updateMarkers(busData);
    });
  }

  void updateMarkers(List<BusModel> busData) async {
    _markers.clear();
    for (var bus in busData) {
      if (bus.location != null) {
        var marker = Marker(
          markerId: MarkerId(bus.id!),
          position: LatLng(bus.location!.latitude, bus.location!.longitude),
          icon: await getCustomIcon(active: bus.status ?? false),

          // consumeTapEvents: true,
          onTap: () {
            // Get.to(() => BusDetailPage(bus: bus));
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              context: context,
              builder: (context) {
                return BusDetailPage(bus: bus);
              },
            );
          },
        );
        _markers.add(marker);
      }
    }
    setState(() {}); // Trigger a rebuild with new markers
  }

  Future<BitmapDescriptor> getCustomIcon({required bool active}) async {
    if (active) {
      return BitmapDescriptor.fromBytes(
          await getBytesFromAsset('assets/images/bus_marker.png', 150));
    }
    return BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/images/bus_marker_grey.png', 120));
  }

  @override
  void dispose() {
    _mapMarkerSC.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(7.9059983, 98.3688283),
              zoom: 14.4746,
            ),
            markers: Set<Marker>.from(_markers),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _controller.future.then(
                (value) {
                  value.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: userLatLng.value, zoom: 14.4746),
                    ),
                  );
                },
              );
            },
            myLocationEnabled: true,
          ),
          // list horizontal stream bus
          StreamBuilder<List<BusModel>>(
            stream: FirebaseServices.getStreamBusData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                  height: 150,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (snapshot.data![index].location == null) {
                            Fluttertoast.showToast(
                              msg: "Location not found",
                            );
                            return;
                          }
                          _controller.future.then((value) {
                            value.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                      snapshot.data![index].location!.latitude,
                                      snapshot
                                          .data![index].location!.longitude),
                                  zoom: 15,
                                ),
                              ),
                            );
                          });
                        },
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data![index].name ?? "unknow",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                snapshot.data![index].licensePlate!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                snapshot.data![index].status ?? false
                                    ? "Active"
                                    : "Inactive",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: snapshot.data![index].status ?? false
                                      ? AppColors.orange
                                      : AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}

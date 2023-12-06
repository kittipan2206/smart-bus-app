import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/bus_detail_page.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_info_dialog.dart';
import 'package:smart_bus/services/firebase_services.dart';

class MapScreen extends StatefulWidget {
  static const id = "HOME_SCREEN";

  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final List<Marker> _markers = <Marker>[];
  final List<Marker> _busStopMarkers = <Marker>[];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  RxString followBusId = "".obs;

  final _mapMarkerSC = StreamController<List<Marker>>();

  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  @override
  void initState() {
    super.initState();
    // stream getX variable
    busStopList.listen((busStopData) {
      updateBusStopMarkers(busStopData);
    });
    // updateBusStopMarkers(busStopList);
    FirebaseServices.getStreamBusData().listen((busData) {
      if (followBusId.value != "") {
        final bus =
            busData.firstWhere((element) => element.id == followBusId.value);
        _controller.future.then((value) {
          value.animateCamera(
            CameraUpdate.newLatLng(
                LatLng(bus.location!.latitude, bus.location!.longitude)),
          );
        });
      }
      updateBusMarkers(busData);
    });
  }

  void updateBusStopMarkers(List<BusStopModel> busStopData) async {
    _busStopMarkers.clear();
    try {
      for (var busStop in busStopData) {
        final marker = Marker(
          markerId: MarkerId(busStop.id),
          position:
              LatLng(busStop.location.latitude, busStop.location.longitude),
          icon: await getCustomIconBusStop(),
          onTap: () {
            // Get.to(() => BusDetailPage(bus: bus));
            Get.dialog(BusInfoDialog(busStopInLine: busStop));
          },
        );
        _busStopMarkers.add(marker);
      }

      setState(() {}); // Trigger a rebuild with new markers
    } catch (e) {
      logger.e(e);
    }
  }

  void updateBusMarkers(List<BusModel> busData) async {
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
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    // follow bus button
                    Obx(() => ElevatedButton(
                        onPressed: () {
                          if (followBusId.value == bus.id) {
                            followBusId.value = "";
                            return;
                          }
                          followBusId.value = bus.id!;
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: followBusId.value == bus.id
                              ? AppColors.red
                              : AppColors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: followBusId.value == bus.id
                            ? const Text('Unfollow')
                            : const Text('Follow'))),
                    Expanded(child: BusDetailPage(bus: bus)),
                  ],
                );
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
      return BitmapDescriptor.fromBytes(await getBytesFromAsset(
          'assets/images/bus_marker.png', kIsWeb ? 100 : 150));
    }
    return BitmapDescriptor.fromBytes(await getBytesFromAsset(
        'assets/images/bus_marker_grey.png', kIsWeb ? 90 : 120));
  }

  Future<BitmapDescriptor> getCustomIconBusStop() async {
    return BitmapDescriptor.fromBytes(await getBytesFromAsset(
        'assets/images/bus-stop_marker.png', kIsWeb ? 120 : 160));
  }

  @override
  void dispose() {
    _mapMarkerSC.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // stop follow bus
          Obx(() => followBusId.value != ""
              ? FloatingActionButton.extended(
                  onPressed: () {
                    followBusId.value = "";
                  },
                  // rectangular button with rounded corners
                  isExtended: true,
                  label: const Text('Stop follow bus'),
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                )
              : const SizedBox()),
          const SizedBox(height: 10),

          FloatingActionButton.extended(
              onPressed: () {
                if (selectedBusStopIndex.value == -1) {
                  Fluttertoast.showToast(
                    msg: "Please select bus stop",
                  );
                  return;
                }
                _controller.future.then((value) {
                  value.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                          busStopList[selectedBusStopIndex.value]
                              .location
                              .latitude,
                          busStopList[selectedBusStopIndex.value]
                              .location
                              .longitude),
                    ),
                  );
                });
              },
              // rectangular button with rounded corners
              isExtended: true,
              label: const Text('Selected bus stop')),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
              onPressed: () {
                _controller.future.then((value) {
                  value.animateCamera(
                    CameraUpdate.newLatLng(LatLng(
                        userLatLng.value.latitude, userLatLng.value.longitude)),
                  );
                });
              },
              // rectangular button with rounded corners
              isExtended: true,
              label: const Text('My location')),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(7.9059983, 98.3688283),
              zoom: 14.4746,
            ),
            markers: {
              ..._markers,
              ..._busStopMarkers,
            },
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

          Column(
            children: [
              const SizedBox(height: 50),
              ExpansionTile(
                  title: const Text(
                    'Show all bus',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.orange),
                  ),
                  children: [
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
                                    if (snapshot.data![index].location ==
                                        null) {
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
                                                snapshot.data![index].location!
                                                    .latitude,
                                                snapshot.data![index].location!
                                                    .longitude),
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
                                          color:
                                              AppColors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    margin: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          snapshot.data![index].name ??
                                              "unknow",
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
                                            color:
                                                snapshot.data![index].status ??
                                                        false
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
                    )
                  ]),
            ],
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

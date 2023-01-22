import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'busModel.dart';
import 'login_page.dart';
// google map package
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
// geolocator package
import 'package:geolocator/geolocator.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bus',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Smart Bus'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isLogin = false;
  Location currentLocation = Location();
  // marker
  Set<Marker> _markers = {};
  late LocationData _locationData;
  LatLng userLatLng = LatLng(37.43296265331129, -122.08832357078792);
  BitmapDescriptor userMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor BusMarkerIcon = BitmapDescriptor.defaultMarker;
  SharedPreferences? prefs;
  List<Bus> busList = [];
  List<Bus> busSearchList = [];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );

  CameraPosition _currentLocationCam =
      CameraPosition(target: LatLng(7.893887, 98.3541934), zoom: 18);

  @override
  void initState() {
    super.initState();
    checkLogin();
    Fluttertoast.showToast(msg: 'Getting Current Location');
    getCurrentLocation().then((value) {
      Fluttertoast.showToast(msg: 'Get Current Location Success');
    });

    setCustomMarker();
  }

  // stream bus location from firebase
  streamBusLocation() async {
    FirebaseFirestore.instance.collection('bus_data').get().then((value) {
      value.docs.forEach((element) {
        // // get geo point
        // GeoPoint geoPoint = element['location'];
        // print('${element.id}${geoPoint.latitude}, ${geoPoint.longitude}');
        // listen to bus location
        FirebaseFirestore.instance
            .collection('bus_data')
            .doc(element.id)
            .snapshots()
            .listen((event) async {
          GeoPoint geoPoint = event['location'];
          print('${element.id}${geoPoint.latitude}, ${geoPoint.longitude}');
          // update bus location
          final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
          dynamic gDistanceApi = await getDistance(busLatLng: latLng);
          // print(distanceObj);
          try {
            String distance =
                gDistanceApi['rows'][0]['elements'][0]['distance']['text'];
            String duration =
                gDistanceApi['rows'][0]['elements'][0]['duration']['text'];

            print('distance: $distance');
            print('duration: $duration');
            busList.add(Bus(
              id: element.id,
              name: element['name'],
              location: geoPoint,
              distance: distance,
              duration: duration,
            ));
            print('list' + busList.length.toString());
            setState(() {
              // _markers.removeWhere((element) => element.markerId.value == 'bus');
              addBusMarker(
                  element.id, latLng, element['name'], distance, duration);
            });
          } catch (e) {
            print(e);
          }
        });
        // addBusMarker(element.id, LatLng(geoPoint.latitude, geoPoint.longitude));
      });
    });
  }

  void setCustomMarker() async {
    BusMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(0.1, 0.1)),
        'assets/marker/bus_marker.png');
    userMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(0.1, 0.1)),
        'assets/marker/user_marker.png');
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      // Use current location
      _locationData = currentLocation;
      userLatLng = LatLng(_locationData.latitude!, _locationData.longitude!);
      setState(() {
        _markers.add(Marker(
            markerId: const MarkerId('user'),
            position: userLatLng,
            icon: userMarkerIcon));
        _currentLocationCam = CameraPosition(target: userLatLng, zoom: 18);
        // _goToCurrentLocation();
      });
    });
  }

  Future<void> checkLogin() async {
    prefs = await SharedPreferences.getInstance();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) {
      streamBusLocation();
    }).catchError((e) => Fluttertoast.showToast(msg: e.toString()));
    _isLogin = (prefs!.getBool('isLogin') ?? false);
    // if (!_isLogin) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const LoginPage()),
    //   );
    // }
  }

  TextEditingController _searchController = TextEditingController();
  bool _isSearch = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: _goToCurrentLocation,
          // label: const Text('To Current Location'),
          child: Icon(Icons.location_on)),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              icon: Icon(Icons.login)),
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                prefs!.setBool('isLogin', false);
                Fluttertoast.showToast(msg: 'Logout');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            FutureBuilder(builder: (context, snapshot) {
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _currentLocationCam,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: _markers,
                zoomControlsEnabled: false,
              );
            }),
            // animated search bar when click search icon
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _isSearch ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: const Offset(0, 5))
                    ]),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            busSearchList = busList
                                .where((element) => element.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            icon: Icon(Icons.search)),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearch = false;
                            _searchController.clear();
                            busSearchList.clear();
                          });
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
              ),
            ),
            // search icon
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 10,
              right: _isSearch ? -100 : 10,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearch = true;
                  });
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: const Offset(0, 5))
                      ]),
                  child: const Icon(Icons.search),
                ),
              ),
            ),

            // show busSearchList
            if (busSearchList.isNotEmpty && _searchController.text.isNotEmpty)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Container(
                  height: busSearchList.length < 6
                      ? busSearchList.length * 80.0
                      : 400,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: const Offset(0, 5))
                      ]),
                  child: ListView.separated(
                      physics: busSearchList.length < 6
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      itemCount: busSearchList.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            changeCameraPosition(LatLng(
                                busSearchList[index].location.latitude,
                                busSearchList[index].location.longitude));
                            setState(() {
                              busSearchList.clear();
                              _searchController.clear();
                            });
                          },
                          leading: Icon(Icons.directions_bus),
                          title: Text(busSearchList[index].name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Distance: ${busSearchList[index].distance}'),
                              Text(
                                  'Duration: ${busSearchList[index].duration}'),
                            ],
                          ),
                        );
                      }),
                ),
              )
            else
            // show not found
            if (_searchController.text.isNotEmpty)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: const Offset(0, 5))
                      ]),
                  child: const Center(
                    child: Text('Not Found'),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    await getCurrentLocation();
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(_currentLocationCam));
  }

  changeCameraPosition(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 18)));
  }

  Future<dynamic> getDistance({required LatLng busLatLng}) async {
    String Url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${userLatLng.latitude},${userLatLng.longitude}&origins=${busLatLng.latitude},${busLatLng.longitude}&key=AIzaSyCaGjSBHkRCXtTB8u0H9yeErCPg6xDVLD8';
    try {
      var response = await http.get(
        Uri.parse(Url),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else
        return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void addBusMarker(String busId, LatLng busLatLng, String busName,
      String distance, String duration) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(busId),
        position: busLatLng,
        infoWindow: InfoWindow(
            title: busName,
            snippet: 'Distance: $distance, Duration: $duration'),
        icon: BusMarkerIcon,
        onTap: (() => getDistance(busLatLng: busLatLng)),
      ));
      print(_markers.length);
    });
  }
}

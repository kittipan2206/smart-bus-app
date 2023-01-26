import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/setting.dart';
import 'busModel.dart';
import 'login_page.dart';
// google map package
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // alert dialog
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.green,
            shape:
                CircleBorder(side: BorderSide(color: Colors.white, width: 2))),
        primarySwatch: Colors.green,
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
  bool _getGoogleApi = false;

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
  Timer? timer1;
  // FirebaseAuth? auth;
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
    // Fluttertoast.showToast(msg: 'Getting Current Location');
    getCurrentLocation().then((value) {
      _goToCurrentLocation();
      checkLogin();
    });

    setCustomMarker();
  }

  // stream bus location from firebase
  streamBusLocation() async {
    FirebaseFirestore.instance.collection('bus_data').get().then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection('bus_data')
            .doc(element.id)
            .snapshots()
            .listen((event) async {
          GeoPoint geoPoint = event['location'];
          print('${element.id}${geoPoint.latitude}, ${geoPoint.longitude}');
          // update bus location
          final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
          dynamic gDistanceApi = {
            'rows': [
              {
                'elements': [
                  {
                    'status': 'N/A',
                    'distance': {'text': 'N/A', 'value': 0},
                    'duration': {'text': 'N/A', 'value': 0}
                  }
                ]
              }
            ],
            'origin_addresses': ['N/A']
          };

          try {
            String distance = 'Not available';
            String duration = 'Not available';
            int distanceValue = 0;
            String originAddress = 'Not available';
            int durationValue = 0;
            // String distance =
            //     gDistanceApi['rows'][0]['elements'][0]['distance']['text'];
            // String duration =
            //     gDistanceApi['rows'][0]['elements'][0]['duration']['text'];
            // int distanceValue =
            //     gDistanceApi['rows'][0]['elements'][0]['distance']['value'];
            // String originAddress =
            //     gDistanceApi['origin_addresses'][0].toString();
            // int durationValue =
            //     gDistanceApi['rows'][0]['elements'][0]['duration']['value'];
            print(_getGoogleApi);
            if (_getGoogleApi) {
              dynamic gDistanceApi = await getDistance(busLatLng: latLng);
              print(gDistanceApi);
              if (gDistanceApi['rows'][0]['elements'][0]['status'] == 'OK' &&
                  _getGoogleApi == true) {
                distance =
                    gDistanceApi['rows'][0]['elements'][0]['distance']['text'];
                duration =
                    gDistanceApi['rows'][0]['elements'][0]['duration']['text'];
                distanceValue =
                    gDistanceApi['rows'][0]['elements'][0]['distance']['value'];
                originAddress = gDistanceApi['origin_addresses'][0].toString();
                durationValue =
                    gDistanceApi['rows'][0]['elements'][0]['duration']['value'];
              }
            }

            print('distance: $distance');
            print('duration: $duration');
            // busList.add(Bus(
            //   id: element.id,
            //   name: element['name'],
            //   location: geoPoint,
            //   distance: distance,
            //   duration: duration,
            // ));
            // print('list' + busList.length.toString());

            setState(() {
              addBusMarker(
                  element.id, latLng, element['name'], distance, duration);
              busList.removeWhere((element) => element.id == event.id);
              busList.add(Bus(
                id: event.id,
                name: event['name'],
                location: geoPoint,
                distance: distance,
                duration: duration,
                distanceInMeters: distanceValue,
                address: originAddress,
                durationInSeconds: durationValue,
              ));
            });
          } catch (e) {
            // Fluttertoast.showToast(msg: 'Error: $e');
            print(e);
          }
        });
        // addBusMarker(element.id, LatLng(geoPoint.latitude, geoPoint.longitude));
      });
      setState(() {
        // sort bus list by distance
        busList
            .sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
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

  getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    prefs = await SharedPreferences.getInstance();

    _getGoogleApi = prefs!.getBool('googleDistanceMatrixAPI') ?? false;

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
    // filter location
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 3000, distanceFilter: 1);

    // get first location
    _locationData = await location.getLocation();
    userLatLng = LatLng(_locationData.latitude!, _locationData.longitude!);
    _currentLocationCam = CameraPosition(target: userLatLng, zoom: 18);

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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) {
      streamBusLocation();
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    auth = FirebaseAuth.instance;
    _isLogin = auth.currentUser != null;
    print('isLogin: $_isLogin');
    print('auth.currentUser: ${auth.currentUser?.email}');
    print('auth.currentUser: ${auth.currentUser?.displayName}');
    // _isLogin = (prefs!.getBool('isLogin') ?? false);

    // if (!_isLogin) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const LoginPage()),
    //   );
    // }
  }

  int? _selectedBusIndex;

  TextEditingController _searchController = TextEditingController();
  bool _isSearch = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    showAllBusModal();
                  },
                  icon: Icon(Icons.list)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearch = !_isSearch;
                    });
                  },
                  icon: Icon(Icons.search)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
          onLongPress: () {},
          onTap: _selectedBusIndex == null
              ? _goToCurrentLocation
              : () {
                  Fluttertoast.showToast(
                      msg: 'Stop Tracking', gravity: ToastGravity.TOP);
                  setState(() {
                    _selectedBusIndex = null;
                  });
                },
          // label: const Text('To Current Location'),

          child: FloatingActionButton(
            onPressed: null,
            child: _selectedBusIndex == null
                ? Icon(Icons.location_history)
                : Icon(Icons.stop),
            backgroundColor: _selectedBusIndex == null ? null : Colors.red,
          )),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingPage()));
              },
              icon: Icon(Icons.settings)),
          _isLogin
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  icon: Icon(Icons.login))
              : IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // prefs!.setBool('isLogin', false);
                    // Fluttertoast.showToast(msg: 'Logout');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            FutureBuilder(builder: (context, snapshot) {
              return GoogleMap(
                // mapType: MapType.normal,
                trafficEnabled: true,
                padding: const EdgeInsets.only(top: 70),
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
                            // close keyboard
                            FocusScope.of(context).unfocus();
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
              top: 20,
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
                            // build empty to push to bus dialog
                            showDialog(
                                context: context,
                                builder: (context) => const Dialog());
                            busDialog(index);
                            // changeCameraPosition(LatLng(
                            //     busSearchList[index].location.latitude,
                            //     busSearchList[index].location.longitude));
                            // setState(() {
                            //   busSearchList.clear();
                            //   _searchController.clear();
                            // });
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
              ),
            _selectedBusIndex != null
                ? Container(
                    alignment: Alignment.center,
                    // min width
                    width: 250,
                    height: 50,
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus),
                        Text(' Following: '),
                        Text(busList[_selectedBusIndex!].name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  showAllBusModal() {
    return showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        anchorPoint: const Offset(0, 0.5),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              child: Column(
                children: [
                  // bar show all bus
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Container(
                      height: 50,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'Show All Bus',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close))
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    // thickness: 2,
                  ),
                  Expanded(
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          // childAspectRatio: 1.5,
                          crossAxisCount: 2,
                          // childAspectRatio: 0.1,
                          // mainAxisExtent: 150,
                        ),
                        // physics: const NeverScrollableScrollPhysics(),
                        itemCount: busList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              busDialog(index);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 1,
                                        offset: const Offset(0, 1))
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(busList[index].distance,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: busList[index]
                                                        .durationInSeconds >
                                                    240
                                                ? Colors.red
                                                : Colors.green,
                                          )),
                                      Text(busList[index].duration,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: busList[index]
                                                        .durationInSeconds >
                                                    240
                                                ? Colors.red
                                                : Colors.green,
                                          )),
                                    ],
                                  ),
                                  Text(busList[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25)),

                                  Text('Now at: \n${busList[index].address}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  // Text('Distance: ${busList[index].distance}',
                                  //     style: const TextStyle(
                                  //         fontSize: 10, color: Colors.grey)),
                                  // Text('Duration: ${busList[index].duration}',
                                  //     style: const TextStyle(
                                  //         fontSize: 10, color: Colors.grey)),
                                  Center(
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: _selectedBusIndex == index
                                                  ? Colors.red
                                                  : Colors.green),
                                        ),
                                        onPressed: () {
                                          _selectedBusIndex == index
                                              ? setState(() {
                                                  _selectedBusIndex = null;
                                                })
                                              : setState(() {
                                                  Navigator.pop(context);
                                                  alwaysCameraPosition(index);
                                                });
                                        },
                                        child: Text(
                                          _selectedBusIndex == index
                                              ? 'Stop follow'
                                              : 'Follow',
                                          style: TextStyle(
                                              color: _selectedBusIndex == index
                                                  ? Colors.red
                                                  : Colors.green),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            );
          });
        });
  }

  alwaysCameraPosition(int busIndex) async {
    timer1?.cancel();
    setState(() {
      _selectedBusIndex = busIndex;
    });
    changeCameraPosition(LatLng(busList[busIndex].location.latitude,
        busList[busIndex].location.longitude));

    if (_selectedBusIndex != null) {
      // getposition every 5s
      timer1 = Timer.periodic(const Duration(seconds: 2), (timer) {
        changeCameraPosition(
          LatLng(busList[busIndex].location.latitude,
              busList[busIndex].location.longitude),
        );
        print('change camera position');
        if (_selectedBusIndex == null) timer.cancel();
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    await getCurrentLocation();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(userLatLng));
  }

  changeCameraPosition(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  Future<dynamic> getDistance({required LatLng busLatLng}) async {
    String Url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${userLatLng.latitude},${userLatLng.longitude}&origins=${busLatLng.latitude},${busLatLng.longitude}&key=AIzaSyCaGjSBHkRCXtTB8u0H9yeErCPg6xDVLD8';
    try {
      print("user lat long api get" + userLatLng.toString());
      var response = await http.get(
          Uri.parse(
            Url,
          ),
          headers: {
            "Access-Control-Allow-Origin": "*",
            'Content-Type': 'application/json',
            'Accept': '*/*'
          });
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
    _markers.add(Marker(
        markerId: MarkerId(busId),
        // draggable: true,
        // onDragEnd: (newPosition) {
        //   print(newPosition);
        // },
        position: busLatLng,
        infoWindow: InfoWindow(
            title: busName, snippet: 'Distance: $distance Duration: $duration'),
        icon: BusMarkerIcon,
        onTap: () {
          // showDialog(context: context, builder: (context) => Dialog());
        }));
  }

  void busDialog(index) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(busList[index].name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25)),
                  OutlinedButton(
                      onPressed: () {
                        // pop two times
                        Navigator.pop(context);
                        alwaysCameraPosition(index);
                        setState(() {
                          _isSearch = false;
                          _searchController.clear();
                          // close keyboard
                          FocusScope.of(context).unfocus();
                        });
                      },
                      child: Text("Follow"))
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Bus ID: ${busList[index].id}'),
                  Text('Bus Status: ${busList[index].status}'),
                  Text('Distance:\t${busList[index].distance}'),
                  Text('Duration:\t${busList[index].duration}'),
                  Text('Now at: ${busList[index].address}'),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      changeCameraPosition(LatLng(
                          busList[index].location.latitude,
                          busList[index].location.longitude));
                    },
                    child: Text('Go to bus Location')),
              ],
            );
          });
        });
  }
}

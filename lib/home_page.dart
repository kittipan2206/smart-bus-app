// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:lottie/lottie.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_bus/globals.dart';
// import 'package:smart_bus/main.dart';

// import 'MapsPage.dart';
// import 'login_page.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     Timer.periodic(const Duration(seconds: 60), (timer) {
//       logger.i('timer');
//       if (busStreamController.isClosed) {
//         return;
//       }
//       if (!isLogin) busStreamController.add(busList[selectedBusIndex ?? 0]);
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     busStreamController.close();
//     isStreamBusLocation = false;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         elevation: 0,
//         backgroundColor: const Color.fromARGB(255, 255, 99, 96),
//         title: Row(
//           children: [
//             !isLogin
//                 ? TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const LoginPage()),
//                       );
//                     },
//                     child: const Text(
//                       'Sign in for bus driver',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   )
//                 : const Text(
//                     'Bus driver mode',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//             const Spacer(),
//             IconButton(
//                 onPressed: () {
//                   showSettingsDialog(context);
//                 },
//                 icon: const Icon(
//                   Icons.settings_rounded,
//                   color: Colors.white,
//                   size: 30,
//                 )),
//           ],
//         ),
//       ),
//       // set background color to FF6260
//       backgroundColor: const Color.fromARGB(255, 255, 99, 96),
//       body: Stack(
//         children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Container(
//                 // height 60% of screen
//                 height: MediaQuery.of(context).size.height * 0.6,
//                 width: double.infinity,
//                 color: Colors.grey[200],
//               )
//             ],
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     Image.asset('assets/images/logo.png', width: 250),
//                     const SizedBox(height: 20),
//                     Card(
//                       color: const Color(0xFFF5A522),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: isLogin
//                               ? Container(
//                                   width: double.infinity,
//                                   child: Card(
//                                       color: Color(0xFFF3EEFF),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(15.0),
//                                         child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text('Bus details',
//                                                   style: TextStyle(
//                                                       color: Color(0xFFB5A0E8),
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 20)),
//                                               SizedBox(
//                                                 height: 10,
//                                               ),
//                                               Text(
//                                                   'Name: ${allBusList.first['name']}',
//                                                   style: TextStyle(
//                                                       color: Color(0xFFB5A0E8),
//                                                       fontSize: 16)),
//                                               Text(
//                                                   'License plate: ${allBusList.first['LP']}',
//                                                   style: TextStyle(
//                                                       color: Color(0xFFB5A0E8),
//                                                       fontSize: 16)),
//                                             ]),
//                                       )),
//                                 )
//                               : Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         const Text(
//                                           'Selected bus stop',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 20),
//                                         ),
//                                         const Spacer(),
//                                         DropdownButton(
//                                             items: [
//                                               DropdownMenuItem(
//                                                 value: 1,
//                                                 child: Row(
//                                                   children: const [
//                                                     Icon(Icons
//                                                         .directions_walk_rounded),
//                                                     SizedBox(width: 10),
//                                                     Text('Walking'),
//                                                   ],
//                                                 ),
//                                               ),
//                                               DropdownMenuItem(
//                                                 value: 2,
//                                                 child: Row(
//                                                   children: const [
//                                                     Icon(Icons
//                                                         .drive_eta_rounded),
//                                                     SizedBox(width: 10),
//                                                     Text('Driving'),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                             onChanged: (value) async {
//                                               final prefs =
//                                                   await SharedPreferences
//                                                       .getInstance();
//                                               var _profile;
//                                               setState(() {
//                                                 switch (value) {
//                                                   case 1:
//                                                     _profile = 'foot-walking';
//                                                     break;
//                                                   case 2:
//                                                     _profile = 'driving-car';
//                                                     break;
//                                                   default:
//                                                     1;
//                                                 }
//                                                 if (_profile == profile) return;
//                                                 prefs.setString(
//                                                     'profile', profile);
//                                               });
//                                               if (_profile == profile) return;
//                                               showDialog(
//                                                   context: context,
//                                                   builder: (context) {
//                                                     return AlertDialog(
//                                                       title: const Text(
//                                                           'Profile changed'),
//                                                       content: Text(
//                                                           'Do you want to change the profile to $profile?'),
//                                                       actions: [
//                                                         TextButton(
//                                                             onPressed: () {
//                                                               Navigator.pop(
//                                                                   context);
//                                                             },
//                                                             child: const Text(
//                                                                 'No')),
//                                                         TextButton(
//                                                             onPressed:
//                                                                 () async {
//                                                               // show loading dialog
//                                                               showDialog(
//                                                                   context:
//                                                                       context,
//                                                                   builder:
//                                                                       (context) {
//                                                                     return Center(
//                                                                       child:
//                                                                           CircularProgressIndicator(),
//                                                                     );
//                                                                   });
//                                                               await streamBusLocation();
//                                                               setState(() {});
//                                                               Navigator.pop(
//                                                                   context);
//                                                               Navigator.pop(
//                                                                   context);
//                                                             },
//                                                             child: const Text(
//                                                                 'Yes')),
//                                                       ],
//                                                     );
//                                                   });
//                                             },
//                                             icon: Icon(
//                                               profile == 'foot-walking'
//                                                   ? Icons
//                                                       .directions_walk_rounded
//                                                   : Icons.drive_eta_rounded,
//                                               color: Colors.white,
//                                             )),
//                                         IconButton(
//                                             onPressed: () {},
//                                             icon: const Icon(
//                                               Icons.menu,
//                                               color: Colors.white,
//                                             )),
//                                       ],
//                                     ),
//                                     StreamBuilder(
//                                       stream: busStreamController.stream,
//                                       builder: (context, snapshot) {
//                                         if (!snapshot.hasData)
//                                           return const Text('No data');

//                                         final busInfo = snapshot.data;
//                                         return Card(
//                                           color: Colors.white,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(10.0),
//                                             child: Column(
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     const Icon(
//                                                       Icons.location_on_rounded,
//                                                       color: Colors.green,
//                                                     ),
//                                                     const SizedBox(
//                                                       width: 10,
//                                                     ),
//                                                     Text(
//                                                       busInfo!.name.length > 15
//                                                           ? busInfo.name
//                                                                   .substring(
//                                                                       0, 15) +
//                                                               '...'
//                                                           : busInfo!.name,
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 20),
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                     const Spacer(),
//                                                     TextButton(
//                                                         onPressed: () {
//                                                           busDialog(
//                                                               selectedBusIndex ??
//                                                                   0);
//                                                         },
//                                                         child: const Text(
//                                                           'Show more',
//                                                           style: TextStyle(
//                                                               color: Color(
//                                                                   0xFFF5A522)),
//                                                         )),
//                                                   ],
//                                                 ),
//                                                 Center(
//                                                     child: Column(
//                                                   children: [
//                                                     const Text(
//                                                       'Expected to arrive in about',
//                                                       style: TextStyle(
//                                                           color: Colors.grey,
//                                                           fontSize: 15),
//                                                     ),
//                                                     Text(
//                                                       busInfo.getDuration(),
//                                                       style: TextStyle(
//                                                           color:
//                                                               Color(0xFFF5A522),
//                                                           fontSize: 30,
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       children: [
//                                                         Text(
//                                                           'Distance about ',
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.grey,
//                                                               fontSize: 15),
//                                                         ),
//                                                         Text(
//                                                           busInfo.getDistance(),
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.grey,
//                                                               fontSize: 15,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     const Divider(
//                                                       color: Colors.grey,
//                                                     ),
//                                                     const Text(
//                                                       'The next bus is expected to arrive',
//                                                       style: TextStyle(
//                                                           color: Colors.grey,
//                                                           fontSize: 13),
//                                                     ),
//                                                     Card(
//                                                       color: Colors.grey[100],
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(10.0),
//                                                         child: Column(
//                                                           children: [
//                                                             Row(
//                                                               children: [
//                                                                 Text(
//                                                                   'Bus license plate: ${allBusList[0]['LP']}',
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color: Colors
//                                                                         .black,
//                                                                   ),
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                 ),
//                                                                 const Spacer(),
//                                                                 Column(
//                                                                   children: [
//                                                                     Text(
//                                                                       (allBusList[0]['matrix']['distance'][0] <
//                                                                               1000)
//                                                                           ? '${allBusList[0]['matrix']['distance'][selectedBusIndex].toStringAsFixed(0)} m'
//                                                                           : '${(allBusList[0]['matrix']['distance'][selectedBusIndex] / 1000).toStringAsFixed(1)} km',
//                                                                       style: TextStyle(
//                                                                           color: Color(
//                                                                               0xFFF5A522),
//                                                                           fontSize:
//                                                                               15),
//                                                                     ),
//                                                                     Text(
//                                                                       (allBusList[0]['matrix']['duration'][selectedBusIndex] <
//                                                                               3600)
//                                                                           ? '${(allBusList[0]['matrix']['duration'][selectedBusIndex] / 60).toStringAsFixed(0)} min'
//                                                                           : '${(allBusList[0]['matrix']['duration'][selectedBusIndex] / 3600).toStringAsFixed(0)} hr ${(allBusList[0]['matrix']['duration'][selectedBusIndex] % 3600 / 60).toStringAsFixed(0)} min',
//                                                                       style: TextStyle(
//                                                                           color: Color(
//                                                                               0xFFF5A522),
//                                                                           fontSize:
//                                                                               15,
//                                                                           fontWeight:
//                                                                               FontWeight.bold),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                             ElevatedButton(
//                                                                 onPressed: () {
//                                                                   Navigator.push(
//                                                                       context,
//                                                                       MaterialPageRoute(
//                                                                           builder: (context) =>
//                                                                               const MapsPage()));
//                                                                 },
//                                                                 child:
//                                                                     const Text(
//                                                                         'Track'))
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ))
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                     Center(
//                                       child: TextButton(
//                                           onPressed: () {
//                                             showAllBusModal();
//                                           },
//                                           child: const Text(
//                                             'Choose another bus stop',
//                                             style: TextStyle(
//                                                 color: Color(0xFFFF6260)),
//                                           )),
//                                     )
//                                   ],
//                                 )),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Card(
//                       color: Colors.white,
//                       child: Container(
//                         width: double.infinity,
//                         child: Padding(
//                           padding: const EdgeInsets.all(15.0),
//                           child: isLogin
//                               ? Column(
//                                   children: [
//                                     Icon(
//                                       isStreamBusLocation
//                                           ? Icons.location_on
//                                           : Icons.location_off,
//                                       size: 50,
//                                     ),
//                                     const SizedBox(
//                                       height: 10,
//                                     ),
//                                     Text(
//                                       isStreamBusLocation
//                                           ? 'Sharing the location of this bus'
//                                           : 'Location sharing has not started yet.',
//                                       style: TextStyle(
//                                           color: Colors.grey, fontSize: 15),
//                                     ),
//                                     const SizedBox(
//                                       height: 20,
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Share your bus location',
//                                           style: TextStyle(fontSize: 18),
//                                         ),
//                                         const SizedBox(
//                                           height: 10,
//                                         ),
//                                         ElevatedButton(
//                                             // Full width button
//                                             style: ElevatedButton.styleFrom(
//                                                 backgroundColor:
//                                                     isStreamBusLocation
//                                                         ? Color(0xFFFF6260)
//                                                         : Color(0xFFF5A522),
//                                                 minimumSize:
//                                                     const Size.fromHeight(50)),
//                                             onPressed: () {
//                                               if (isStreamBusLocation) {
//                                                 setState(() {
//                                                   isStreamBusLocation = false;
//                                                 });
//                                               } else {
//                                                 setState(() {
//                                                   isStreamBusLocation = true;
//                                                 });
//                                               }
//                                             },
//                                             child: Text(
//                                                 isStreamBusLocation
//                                                     ? 'Stop'
//                                                     : 'Start',
//                                                 style:
//                                                     TextStyle(fontSize: 18))),
//                                       ],
//                                     ),
//                                   ],
//                                 )
//                               : Center(
//                                   child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Image.asset(
//                                       'assets/images/bus_logo.png',
//                                       height: 100,
//                                     ),
//                                     const Text(
//                                       "You haven't tracked any bus yet",
//                                       style: TextStyle(
//                                           color: Colors.grey, fontSize: 15),
//                                     ),
//                                   ],
//                                 )),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   showAllBusModal() {
//     return showModalBottomSheet(
//         isScrollControlled: true,
//         useSafeArea: true,
//         anchorPoint: const Offset(0, 0.5),
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               child: Column(
//                 children: [
//                   // bar show all bus
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
//                     child: Container(
//                       height: 50,
//                       child: Row(
//                         children: [
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           const Text(
//                             'Choose a bus stop',
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               icon: const Icon(Icons.close))
//                         ],
//                       ),
//                     ),
//                   ),
//                   Divider(
//                     height: 1,
//                     // thickness: 2,
//                   ),
//                   Expanded(
//                     child: ListView.builder(

//                         // physics: const NeverScrollableScrollPhysics(),
//                         itemCount: busList.length,
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: () {
//                               selectedBusIndex = index;
//                               busStreamController.add(busList[index]);
//                               Navigator.pop(context);
//                             },
//                             child: Container(
//                               margin: const EdgeInsets.all(10),
//                               padding: const EdgeInsets.all(10),
//                               height: selectedBusIndex == index ? 150 : 100,
//                               decoration: BoxDecoration(
//                                   color: selectedBusIndex == index
//                                       ? Colors.green[100]
//                                       : Colors.white,
//                                   borderRadius: BorderRadius.circular(20),
//                                   boxShadow: [
//                                     if (selectedBusIndex == index)
//                                       const BoxShadow(
//                                           color: Colors.green,
//                                           blurRadius: 1,
//                                           offset: Offset(0, 1))
//                                   ]),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(busList[index].getDistance(),
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: selectedBusIndex == index
//                                                 ? 15
//                                                 : 10,
//                                             color: busList[index]
//                                                         .durationInSeconds >
//                                                     240
//                                                 ? Colors.red
//                                                 : Colors.green,
//                                           )),
//                                       Text(busList[index].getDuration(),
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: selectedBusIndex == index
//                                                 ? 15
//                                                 : 10,
//                                             color: busList[index]
//                                                         .durationInSeconds >
//                                                     240
//                                                 ? Colors.red
//                                                 : Colors.green,
//                                           )),
//                                     ],
//                                   ),
//                                   Text(busList[index].name,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         fontSize:
//                                             selectedBusIndex == index ? 20 : 18,
//                                         fontWeight: selectedBusIndex == index
//                                             ? FontWeight.bold
//                                             : FontWeight.normal,
//                                       )),

//                                   Text('Now at: \n${busList[index].address}',
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 4,
//                                       style: TextStyle(
//                                           fontSize: selectedBusIndex == index
//                                               ? 15
//                                               : 12,
//                                           color: selectedBusIndex == index
//                                               ? Colors.black
//                                               : Colors.grey)),
//                                   // Text('Distance: ${busList[index].distance}',
//                                   //     style: const TextStyle(
//                                   //         fontSize: 10, color: Colors.grey)),
//                                   // Text('Duration: ${busList[index].duration}',
//                                   //     style: const TextStyle(
//                                   //         fontSize: 10, color: Colors.grey)),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }),
//                   ),
//                 ],
//               ),
//             );
//           });
//         });
//   }

//   busDialog(index) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Flexible(
//                     child: Text(busList[index].name,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 25),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 2),
//                   ),
//                 ],
//               ),
//               content: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Distance: ' + busList[index].getDistance(),
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: busList[index].durationInSeconds > 240
//                             ? Colors.green
//                             : Colors.red,
//                       )),
//                   Text('Duration: ' + busList[index].getDuration(),
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: busList[index].durationInSeconds > 240
//                             ? Colors.green
//                             : Colors.red,
//                       )),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Text('Now at: \n${busList[index].address}',
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 4,
//                       style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Close')),
//               ],
//             );
//           });
//         });
//   }

//   void showSettingsDialog(BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Settings'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   enabled: isLogin,
//                   // logout
//                   title: Row(children: const [
//                     Icon(Icons.logout),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text('Logout')
//                   ]),
//                   onTap: () async {
//                     // loading
//                     showDialog(
//                         context: context,
//                         builder: (context) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         });
//                     await FirebaseAuth.instance.signOut();
//                     isLogin = false;
//                     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
//                       builder: (context) {
//                         return const LoadingPage();
//                       },
//                     ), (route) => false);
//                   },
//                 )
//               ],
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Close')),
//             ],
//           );
//         });
//   }
// }

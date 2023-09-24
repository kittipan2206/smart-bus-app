// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_bus/login_page.dart';
// import 'package:smart_bus/select_bus_stop_page.dart';

// import 'firebase_options.dart';
// import 'globals.dart';
// import 'home_page.dart';

// void main() async {
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Smart Bus',
//       theme: ThemeData(
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             elevation: 1,
//           ),
//           inputDecorationTheme: const InputDecorationTheme(),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: const Color(0xFFF5A522),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//           ),
//           // alert dialog
//           dialogTheme: const DialogTheme(
//             backgroundColor: Colors.white,
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//             ),
//           ),
//           floatingActionButtonTheme: const FloatingActionButtonThemeData(
//             backgroundColor: Colors.green,
//             // shape: CircleBorder(
//             //     side: BorderSide(color: Colors.white, width: 2))
//           ),
//           primarySwatch: Colors.green),
//       home: const LoadingPage(),
//     );
//   }
// }

// class LoadingPage extends StatefulWidget {
//   const LoadingPage({super.key});

//   @override
//   _LoadingPageState createState() => _LoadingPageState();
// }

// class _LoadingPageState extends State<LoadingPage> {
//   String text = 'Loading...';
//   @override
//   void initState() {
//     checkLogin().then((value) {
//       FlutterNativeSplash.remove();
//       if (isLogin) initAll();
//     });

//     super.initState();
//   }

//   Future<void> initAll() async {
//     text = 'Getting current location...';
//     await getCurrentLocation();
//     setState(() {
//       text = 'Checking login...';
//     });
//     await checkProfile();
//     await checkLogin();
//     logger.i('busList: ${busList.length}');
//     if (isLogin) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => const MyHomePage()));
//     } else {
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => const SelectBusStopPage()));
//     }
//   }

//   Future<void> checkLogin() async {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     ).then((value) async {
//       FirebaseAuth auth = FirebaseAuth.instance;
//       isLogin = auth.currentUser != null;
//       if (auth.currentUser != null) {
//         user = auth.currentUser;
//         allBusList.clear();
//         await getBusList();
//         busDriverUID = user!.uid;
//         logger.i(auth.currentUser.runtimeType);
//         logger.i('auth.currentUser: ${auth.currentUser?.email}');
//         logger.i('auth.currentUser: ${auth.currentUser?.displayName}');
//         return;
//       }
//       if (type == null) return;
//       logger.i('isLogin: $isLogin');
//       setState(() {
//         text = 'Fetching bus list...';
//       });
//       await streamBusLocation();
//       await getBusList();
//       Fluttertoast.showToast(msg: 'Firebase initialized');
//     });
//   }

//   String? type;
//   @override
//   Widget build(BuildContext context) {
//     if (type == null) {
//       return SafeArea(
//           child: Scaffold(
//               body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset('assets/images/logo.png', width: 250),
//           Text('Phuket Smart Bus',
//               style: Theme.of(context)
//                   .textTheme
//                   .headlineMedium!
//                   .copyWith(fontWeight: FontWeight.bold)),
//           Text('Select your profile',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleMedium!
//                   .copyWith(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: GridView(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 children: [
//                   ElevatedButton(
//                       onPressed: () async {
//                         await checkLogin();
//                         await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const LoginPage()));
//                       },
//                       child: const Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.directions_bus, size: 50),
//                           Text('Driver', style: TextStyle(fontSize: 20)),
//                         ],
//                       )),
//                   ElevatedButton(
//                       onPressed: () {
//                         type = 'passenger';
//                         initAll();
//                       },
//                       child: const Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.directions_walk, size: 50),
//                           Text('Passenger', style: TextStyle(fontSize: 20)),
//                         ],
//                       )),
//                 ]),
//           ),
//         ],
//       )));
//     }
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 10),
//             Text(text),
//           ],
//         ),
//       ),
//     );
//   }

//   checkProfile() async {
//     final prefs = await SharedPreferences.getInstance();
//     profile = prefs.getString('profile') ?? 'foot-walking';
//     logger.i('profile: $profile');
//   }
// }

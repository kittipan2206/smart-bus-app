import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:smart_bus/MapsPage.dart';
import 'package:smart_bus/login_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
          inputDecorationTheme: const InputDecorationTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFF5A522),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          // alert dialog
          dialogTheme: const DialogTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.green,
              shape: CircleBorder(
                  side: BorderSide(color: Colors.white, width: 2))),
          primarySwatch: Colors.green),
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
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 99, 96),
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                'Sign in for bus driver',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 30,
                )),
          ],
        ),
      ),
      // set background color to FF6260
      backgroundColor: const Color.fromARGB(255, 255, 99, 96),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                // height 60% of screen
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                color: Colors.grey[200],
              )
            ],
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/bus_image1.png',
                      height: 200,
                    ),
                    Card(
                      color: const Color(0xFFF5A522),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Nearest bus stop',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.directions_walk_rounded,
                                        color: Colors.white,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                              Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_rounded,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text(
                                            'Bus stop 1',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          TextButton(
                                              onPressed: () {},
                                              child: const Text(
                                                'Show more',
                                                style: TextStyle(
                                                    color: Color(0xFFF5A522)),
                                              )),
                                        ],
                                      ),
                                      Center(
                                          child: Column(
                                        children: [
                                          const Text(
                                            'Expected to arrive in about',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15),
                                          ),
                                          const Text(
                                            '15 min',
                                            style: TextStyle(
                                                color: Color(0xFFF5A522),
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Distance about',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15),
                                              ),
                                              const Text(
                                                ' 1.5 km',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                          ),
                                          const Text(
                                            'The next bus is expected to arrive',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13),
                                          ),
                                          Card(
                                            color: Colors.grey[100],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Bus license plate: XXXX',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const Spacer(),
                                                      Column(
                                                        children: [
                                                          const Text(
                                                            '800',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFFF5A522),
                                                                fontSize: 15),
                                                          ),
                                                          const Text(
                                                            '15 min',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFFF5A522),
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const MapsPage()));
                                                      },
                                                      child:
                                                          const Text('Track'))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Choose another bus stop',
                                      style:
                                          TextStyle(color: Color(0xFFFF6260)),
                                    )),
                              )
                            ],
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      color: Colors.white,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/bus_logo.png',
                              height: 100,
                            ),
                            const Text(
                              "You haven't tracked any bus yet",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

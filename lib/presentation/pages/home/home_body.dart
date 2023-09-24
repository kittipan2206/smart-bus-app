import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/bus_detail_page.dart';
import 'package:smart_bus/presentation/pages/home/bus_stop_list.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_list.dart';
import 'package:smart_bus/presentation/pages/home/components/courosel.dart';
import 'package:smart_bus/presentation/pages/home/components/group_of_buttons.dart';
import 'package:smart_bus/presentation/pages/home/components/profile_image.dart';
import 'package:smart_bus/presentation/pages/home/components/selected_bus_widget.dart';
import 'package:smart_bus/presentation/pages/home/journey_plan_page.dart';
import 'package:smart_bus/utils/unit.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    // final isDriver = userInfo['roles'] == 'driver';

    // list of names and their icons
    final List<String> names = [
      'Select bus',
      'Journey plan',
      'History',
      'Profile',
    ];
    final List<IconData> icons = [
      Icons.directions_bus,
      Icons.directions,
      Icons.history,
      Icons.person,
    ];

    final List<Function()> onPresseds = [
      () {
        Fluttertoast.showToast(msg: 'This feature is not available yet');
      },
      () {
        Get.to(() => const JourneyPlanPage());
      },
      () {
        Fluttertoast.showToast(msg: 'This feature is not available yet');
      },
      () {
        Fluttertoast.showToast(msg: 'This feature is not available yet');
      },
    ];

    return SingleChildScrollView(
      child: Container(
        // gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 172, 229, 255),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  ProfileImage(),
                  const SizedBox(
                    width: 10,
                  ),
                  Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome to Smart Bus'),
                        isLogin.value
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.value!.displayName ?? 'Guest',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // role
                                  // if (userInfo.data() != null)

                                  Text(
                                    "Role: ${userInfo['roles'] ?? 'Guest'}",
                                  ),
                                ],
                              )
                            : const Text('Guest',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    );
                  }),
                ],
              ),
              Obx(() {
                if (isLogin.value && userInfo['roles'] == 'driver') {
                  if (isStreamBusLocation.value) {
                    return Column(
                      children: [
                        Center(
                          child: // share bus location button
                              ElevatedButton(
                            onPressed: () {
                              isStreamBusLocation.value = false;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Stop share bus location"),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Your location: ${userLatLng.toString()}"),
                      ],
                    );
                  } else {
                    return Center(
                      child: // stop share bus location button
                          ElevatedButton(
                        onPressed: () {
                          isStreamBusLocation.value = true;
                        },
                        child: const Text('Share bus location'),
                      ),
                    );
                  }
                } else {
                  return Container();
                }
              }),
              const SizedBox(
                height: 20,
              ),
              // carousel
              const CarouselSlidePart(),
              const SizedBox(
                height: 20,
              ),
              // Group of buttons
              GroupOfButtons(
                children: [
                  ...List.generate(
                    names.length,
                    (index) => InkWell(
                      onTap: onPresseds[index],
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.lightBlue,
                            ),
                            child: Icon(
                              icons[index],
                              color: Colors.white,
                            ),
                          ),
                          Text(names[index]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                margin: const EdgeInsets.only(top: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Bus status',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      // alignment: Alignment.center,
                      children: [
                        Obx(() {
                          if (selectedBusStopIndex.value == -1) {
                            return const Text(
                              'You have not selected any bus stop',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blue),
                            );
                          }
                          final BusStopModel busStop =
                              busStopList[selectedBusStopIndex.value];
                          final List<BusModel> buses = busList.where((bus) {
                            return busStop.line['line']
                                    .contains(bus.busStopLine) &&
                                bus.status!;
                          }).toList();
                          if (buses.isEmpty) {
                            return const Text(
                              'There is no bus at this bus stop',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blue),
                            );
                          }
                          final nearestBus = buses.first;
                          final busStopInLine = busStopList
                              .where((element) => element.line['line']
                                  .contains(nearestBus.busStopLine))
                              .toList();
                          final nearestDurationTime = UnitUtils.formatDuration(
                              nearestBus.matrix!['duration']
                                  [busStopInLine.indexOf(busStop)]);

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                'assets/lottie/moving-bus.json',
                                fit: BoxFit.cover,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => BusDetailPage(
                                      busIndex: busList.indexOf(nearestBus)));
                                  // Get.dialog(AlertDialog.adaptive(
                                  //   title: const Text('Bus information'),
                                  //   content: Column(
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.start,
                                  //     children: [
                                  //       Text(
                                  //         'Bus name: ${nearestBus.name}',
                                  //       ),
                                  //       Text(
                                  //         'License plate: ${nearestBus.licensePlate}',
                                  //         style: const TextStyle(
                                  //             fontWeight: FontWeight.bold),
                                  //       ),
                                  //       Text(
                                  //         'Next bus stop: ${nearestBus.nextBusStop}',
                                  //         style: const TextStyle(
                                  //             fontWeight: FontWeight.bold),
                                  //       ),
                                  //       Text(
                                  //         'Onward: ${nearestBus.onward}',
                                  //         style: const TextStyle(
                                  //             fontWeight: FontWeight.bold),
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   actions: [
                                  //     TextButton(
                                  //       onPressed: () {
                                  //         Get.back();
                                  //       },
                                  //       child: const Text('Close'),
                                  //     ),
                                  //   ],
                                  // ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.orange.withOpacity(0.4),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  // radius: 50,
                                  // backgroundColor:
                                  //     Colors.transparent.withOpacity(0.4),
                                  // foregroundColor: Colors.white,

                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Next bus arrive in about',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        nearestDurationTime,
                                        // 'test',
                                        style: const TextStyle(
                                            fontSize: 45,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blue),
                                      ),
                                      const Text(
                                        'View more',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.deepBLue),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        }),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: Obx(() {
                                return selectedBusStopIndex.value == -1
                                    ? Container()
                                    : const SelectedBusStopWidget();
                              }),
                            ),
                            Obx(() => FilledButton(
                                onPressed: () {
                                  Get.to(() => const BusStopListPage());
                                },
                                child: Text(selectedBusStopIndex.value == -1
                                    ? 'Select bus stop'
                                    : 'Change bus stop'))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const BusList(),
            ],
          ),
        ),
      ),
    );
  }
}

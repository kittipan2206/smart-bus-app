import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/presentation/pages/authen/register_page.dart';
import 'package:smart_bus/presentation/pages/home/bus_detail_page.dart';
import 'package:smart_bus/presentation/pages/home/bus_stop_list.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_info_dialog.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_line_list.dart';
import 'package:smart_bus/presentation/pages/home/components/courosel.dart';
import 'package:smart_bus/presentation/pages/home/components/group_of_buttons.dart';
import 'package:smart_bus/presentation/pages/home/components/profile_image.dart';
import 'package:smart_bus/presentation/pages/home/components/selected_bus_widget.dart';
import 'package:smart_bus/presentation/pages/home/history_page.dart';
import 'package:smart_bus/presentation/pages/home/journey_plan_page.dart';
import 'package:smart_bus/presentation/pages/home/profile_page.dart';
import 'package:smart_bus/presentation/pages/home/select_bus_page.dart';
import 'package:smart_bus/services/firebase_services.dart';
import 'package:smart_bus/utils/unit.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    // final BusController busController = Get.find();
    final List<String> names = [
      'See all buses',
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
        Get.to(() => const SelectBusPage());
      },
      () {
        Get.to(() => const JourneyPlanPage());
      },
      () {
        Get.to(() => const HistoryPage());
      },
      () {
        Get.to(() => ProfilePage());
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
                        const SizedBox(
                          height: 10,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Lottie.asset(
                              'assets/lottie/moving-bus.json',
                              fit: BoxFit.cover,
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Sharing bus location',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${selectedBusSharingId.value!.name!} - ${selectedBusSharingId.value!.licensePlate!}',
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blue),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    // change bus button
                                    ElevatedButton(
                                      onPressed: () {
                                        final driverBuses =
                                            busList.where((element) {
                                          return element.ownerId ==
                                              user.value!.uid;
                                        }).toList();
                                        changeBusDialog(driverBuses);
                                      },
                                      child: const Text('Change bus'),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseServices.updateStatusBus(
                                        busId: selectedBusSharingId.value!.id!,
                                        status: false);
                                    isStreamBusLocation.value = false;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text("Stop"),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    );
                  } else {
                    final driverBuses = busList.where((element) {
                      return element.ownerId == user.value!.uid;
                    }).toList();
                    if (driverBuses.isEmpty) {
                      return Column(
                        children: [
                          const Text(
                            'You have not added any bus yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blue),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              addBusDialog(rawBusList: busList);
                            },
                            child: const Text('Add bus'),
                          ),
                        ],
                      );
                    }
                    return Center(
                      child: // stop share bus location button
                          Column(
                        children: [
                          Row(
                            children: [
                              const Text('Select bus: '),
                              // dialog button to select bus
                              ElevatedButton(
                                onPressed: () {
                                  changeBusDialog(driverBuses);
                                },
                                child: Obx(
                                  () {
                                    if (selectedBusSharingId.value == null) {
                                      return const Text('Select bus');
                                    }
                                    return Text(// selected bus
                                        '${selectedBusSharingId.value!.name!} - ${selectedBusSharingId.value!.licensePlate!}');
                                  },
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseServices.updateStatusBus(
                                  busId: selectedBusSharingId.value!.id!,
                                  status: true);
                              isStreamBusLocation.value = true;
                              logger.i('start stream bus location');
                            },
                            child: const Text('Share bus location'),
                          ),
                        ],
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
              CarouselSlidePart(
                item: const [
                  'assets/images/ads1.png',
                  'assets/images/ads2.png',
                  'assets/images/ads3.png',
                  'assets/images/ads4.png',
                ],
              ),

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
                        mainAxisAlignment: MainAxisAlignment.center,
                        // mainAxisSize: MainAxisSize.min,
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
                          Text(names[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                // grid view suggested bus stop horizontal scroll
                if (isLogin.value && busStopList.isNotEmpty) {
                  return StreamBuilder(
                      stream: FirebaseServices.getFavoriteBusStop(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return const SizedBox();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Your favorite bus stop',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final busStop = snapshot.data![index];

                                  return InkWell(
                                    onTap: () {
                                      Get.dialog(BusInfoDialog(
                                        busStopInLine: busStop,
                                      ));
                                    },
                                    child: Container(
                                      width: Get.width * 0.8,
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            busStop.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            busStop.address,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      });
                }
                return const SizedBox();
              }),

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
                          return StreamBuilder<List<BusModel>>(
                              stream: FirebaseServices.getStreamBusByLines(
                                  busStopList[selectedBusStopIndex.value]
                                      .line['line']),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text('Something went wrong'),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return const Text(
                                    'There is no bus at this bus stop',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.blue),
                                  );
                                }
                                final busList = snapshot.data!;
                                final List<BusModel> buses =
                                    busList.where((bus) {
                                  final status = bus.status ?? false;
                                  return status;
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
                                var nearestBus = buses.first;

                                for (final bus in buses) {
                                  final busStopInLine = busStopList
                                      .where((element) => element.line['line']
                                          .contains(bus.busStopLine))
                                      .toList();
                                  if (nearestBus.matrix == null) {
                                    nearestBus = bus;
                                    continue;
                                  }
                                  final durationTime = bus.matrix?['duration'][
                                          busStopInLine.indexOf(busStopList[
                                              selectedBusStopIndex.value])] ??
                                      0;

                                  if (durationTime <
                                          nearestBus.matrix?['duration'][
                                              busStopInLine.indexOf(busStopList[
                                                  selectedBusStopIndex
                                                      .value])] ??
                                      0) {
                                    nearestBus = bus;
                                  }
                                }
                                final int order = busStopList[
                                                selectedBusStopIndex.value]
                                            .line['order'][
                                        busStopList[selectedBusStopIndex.value]
                                            .line['line']
                                            .indexOf(nearestBus.busStopLine)] -
                                    1;
                                final nextBus = busStopList.firstWhereOrNull(
                                    (element) =>
                                        element.id == nearestBus.nextBusStop);
                                bool passed = false;
                                if (nextBus != null) {
                                  final nextBusStopIndex =
                                      busStopList.indexOf(nextBus);
                                  // logger.d(indexOfNextBus);
                                  final nextStopOrder =
                                      busStopList[nextBusStopIndex]
                                                  .line['order'][
                                              busStopList[nextBusStopIndex]
                                                  .line['line']
                                                  .indexOf(
                                                      nearestBus.busStopLine)] -
                                          1;
                                  logger.d(nextStopOrder);
                                  // logger.d(nextStopIndex);

                                  if (nearestBus.onward == true ||
                                      nearestBus.onward == null) {
                                    passed = order < nextStopOrder;
                                  } else {
                                    passed = order > nextStopOrder;
                                  }
                                }

                                final nearestTime =
                                    nearestBus.matrix!['duration'][order] ?? 0;
                                final nearestDurationTime =
                                    UnitUtils.formatDuration(
                                        duration: passed ? 0 : nearestTime,
                                        passed: passed);

                                AwesomeNotifications().createNotification(
                                  content: NotificationContent(
                                    id: 10,
                                    channelKey: 'alerts',
                                    title: 'Follow bus',
                                    body:
                                        'Bus is there in about ${nearestTime < 60 ? 'less than a minute' : nearestDurationTime}',
                                    payload: {'uuid': 'uuid-test'},
                                    backgroundColor: Colors.orange,
                                    locked: true,
                                    // progress: int.parse(nearestTime.toString()),
                                  ),
                                  actionButtons: [
                                    NotificationActionButton(
                                      key: 'UNFOLLOW',
                                      label: 'Unfollow',
                                      actionType: ActionType.DismissAction,
                                      isDangerousOption: true,
                                    )
                                  ],
                                );

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/lottie/moving-bus.json',
                                      fit: BoxFit.cover,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.to(() =>
                                            BusDetailPage(bus: nearestBus));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: Colors.orange.withOpacity(0.4),
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        // radius: 50,
                                        // backgroundColor:
                                        //     Colors.transparent.withOpacity(0.4),
                                        // foregroundColor: Colors.white,

                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 30,
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
                              });
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
                                  // NotificationController
                                  //     .createNewNotification();
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

  void changeBusDialog(driverBuses) {
    Get.defaultDialog(
      title: 'Select bus',
      content: Column(
        children: [
          ...List.generate(
            driverBuses.length,
            (index) => ListTile(
              onTap: () {
                selectedBusSharingId.value = driverBuses[index];
                Get.back();
              },
              title: Text(
                driverBuses[index].name ?? '',
              ),
              subtitle: Text(
                driverBuses[index].licensePlate ?? '',
              ),
              leading: CircleAvatar(
                child: Text(
                  driverBuses[index].name![0].toUpperCase(),
                ),
              ),
              trailing: Obx(() {
                if (selectedBusSharingId.value == driverBuses[index]) {
                  return const Icon(
                    Icons.check,
                    color: Colors.green,
                  );
                }
                return const SizedBox();
              }),
            ),
          ),
        ],
      ),
    );
  }
}

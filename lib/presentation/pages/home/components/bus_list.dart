import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/pages/home/controller/bus_controller.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smart_bus/presentation/pages/home/image_viewer_page.dart';

class BusList extends StatelessWidget {
  const BusList({super.key});

  @override
  Widget build(BuildContext context) {
    final BusController busController = Get.find();
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Bus List",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(
          () {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: busController.busLineList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final busStopInLine = busList.value
                    .where((element) => element.line['line']
                        .contains(busController.busLineList[index]))
                    .toList();
                return ExpansionTile(
                  tilePadding: const EdgeInsets.all(15),
                  backgroundColor: AppColors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  collapsedBackgroundColor: AppColors.blue,
                  iconColor: Colors.white,
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  collapsedTextColor: Colors.white,
                  textColor: Colors.black,
                  // if it has decimal, split it and get the first one
                  title: Text(
                      "Line ${busController.busLineList[index].toString().split('.')[0]} ${busController.busLineList[index].toString().split('.').length > 1 ? "Route ${busController.busLineList[index].toString().split('.')[1]}" : ''}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${busStopInLine[0].name} -> ${busStopInLine[busStopInLine.length - 1].name}")

                      // Text("Nearest bus stop: ${busList.value[0].name}",
                      //     style: const TextStyle(
                      //         fontWeight: FontWeight.bold, color: AppColors.orange)),
                    ],
                  ),
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Obx(() {
                        // sort bus list by order

                        var nearest = 0;
                        for (var i = 0; i < busList.value.length; i++) {
                          if (busList.value[i].distanceInMeters <
                              busList.value[nearest].distanceInMeters) {
                            nearest = i;
                          }
                        }
                        final busStopInLine = busList.value
                            .where((element) => element.line['line']
                                .contains(busController.busLineList[index]))
                            .toList();
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Bus stop list: ${busStopInLine.length} stops",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Nearest bus stop: ${busStopInLine[nearest].name}",
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // show image button
                            FilledButton(
                                onPressed: () {
                                  Get.to(() => const ImageViewerPage(
                                      imageUrl:
                                          "https://img.wongnai.com/p/800x0/2020/08/07/f20e7e06eaba4904b3016a22f2872188.jpg"));
                                },
                                child: const Text('Show line map')),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: busStopInLine.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: nearest == index
                                        ? AppColors.orange
                                        : Colors.grey,
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      busStopInLine[index]
                                          .line['order'][0]
                                          .toString(),
                                    ),
                                  ),
                                  title: Text(
                                    busStopInLine[index].name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(busStopInLine[index].address),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(busStopInLine[index].getDistance()),
                                      Text(busStopInLine[index].getDuration()),
                                    ],
                                  ),
                                  onTap: () {
                                    Get.dialog(
                                      AlertDialog.adaptive(
                                        title:
                                            const Text('Bus stop information'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Name: ${busStopInLine[index].name}",
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Address: ${busStopInLine[index].address}",
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Distance: ${busStopInLine[index].getDistance()}",
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Duration: ${busStopInLine[index].getDuration()}",
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            FilledButton(
                                              onPressed: () {
                                                MapsLauncher.launchCoordinates(
                                                    busStopInLine[index]
                                                        .location
                                                        .latitude,
                                                    busStopInLine[index]
                                                        .location
                                                        .longitude);
                                                // MapsLauncher.createCoordinatesUri(
                                                //     busStopInLine[index].location
                                                //         .latitude,
                                                //     busStopInLine[index].location
                                                //         .longitude);
                                                // MapsLauncher.launchQuery(
                                                //     busStopInLine[index].name);
                                              },
                                              child: Center(
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.directions),
                                                    Text(
                                                        "Navigate to this bus"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: const Text('OK'),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
        )
        // ExpansionPanelList(
        //   expansionCallback: (int index, bool isExpanded) {
        //     // setState(() {
        //     //   busList.value[index].isExpanded = !isExpanded;
        //     // });
        //   },
        //   children: busList.value.map<ExpansionPanel>((BusModel bus) {
        //     return ExpansionPanel(
        //       headerBuilder: (BuildContext context, bool isExpanded) {
        //         return ListTile(
        //           leading: const Icon(Icons.directions_bus),
        //           title: Text(bus.name),
        //           subtitle: Text(bus.address),
        //         );
        //       },
        //       body: ListTile(
        //         title: Text(bus.getDistance()),
        //         subtitle: Text(bus.getDuration()),
        //         trailing: const Icon(Icons.directions),
        //         onTap: () {},
        //       ),
        //       // isExpanded: bus.isExpanded,
        //     );
        //   }).toList(),
        // )
        // ListView.builder(
        //   shrinkWrap: true,
        //   physics: const NeverScrollableScrollPhysics(),
        //   itemCount: busList.value.length,
        //   itemBuilder: (context, index) {
        //     return Card(
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(25.0),
        //       ),
        //       child: ListTile(
        //         leading: const Icon(Icons.directions_bus),
        //         title: Text(busList.value[index].name),
        //         subtitle: Text(busList.value[index].address),
        //         trailing: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text(busList.value[index].getDistance()),
        //             Text(busList.value[index].getDuration()),
        //           ],
        //         ),
        //         onTap: () {},
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/extensions/list_extensions.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_info_dialog.dart';
import 'package:smart_bus/presentation/pages/home/controller/bus_controller.dart';
// import 'package:photo_view/photo_view.dart';
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
          "Bus line list",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // lottie animation

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
                return Obx(() {
                  final busStopInLine = busStopList
                      .where((element) => element.line['line']
                          .contains(busController.busLineList[index]["Id"]))
                      .toList();
                  //  final busStopInLine = busStopList
                  //               .where((element) => element.line['line']
                  //                   .contains(busController.busLineList[index]
                  //                       ["Id"]))
                  //               .toList();
                  final firstLine = busStopInLine.firstWhereOrNull(
                      (element) => element.line['order'].contains(1));
                  final lastLine = busStopInLine.firstWhereOrNull((element) =>
                      element.line['order'].contains(busStopInLine.length));
                  return Column(
                    children: [
                      ExpansionTile(
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
                        title: Text(
                            busController.busLineList[index]["name"].toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (busStopInLine.isNotEmpty &&
                                (firstLine != null && lastLine != null))
                              Text('${firstLine.name} - ${lastLine.name}')
                            else
                              const Text("No bus stop"),

                            // Text("Nearest bus stop: ${busList[0].name}",
                            //     style: const TextStyle(
                            //         fontWeight: FontWeight.bold, color: AppColors.orange)),
                          ],
                        ),
                        children: [
                          if (busStopInLine.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 20),
                              child: Text("No bus stop"),
                            )
                          else
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Obx(() {
                                // sort bus list by order

                                var nearest = 0;

                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Bus stop list: ${busStopInLine.length} stops",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Nearest bus stop: ${busStopInLine[nearest].name}",
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // show image button
                                    GestureDetector(
                                        onTap: () {
                                          Get.to(() => ImageViewerPage(
                                              imageUrl: busController
                                                      .busLineList[index]
                                                  ["image"]));
                                        },
                                        child: Image.network(
                                          busController.busLineList[index]
                                              ["image"],
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )),

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: busStopInLine.length,
                                      itemBuilder: (context, indexInLine) {
                                        // order bus stop in line
                                        final lineIndex =
                                            busStopInLine[indexInLine]
                                                    .line['line']
                                                [
                                                busStopInLine[indexInLine]
                                                    .line['line']
                                                    .indexOf(busController
                                                            .busLineList[index]
                                                        ["Id"])];

                                        busStopInLine.sortBy((item) =>
                                            item.line['order'][item.line['line']
                                                .indexOf(lineIndex)]);
                                        for (var i = 0;
                                            i < busStopInLine.length;
                                            i++) {
                                          if (busStopInLine[i]
                                                  .distanceInMeters <
                                              busStopInLine[nearest]
                                                  .distanceInMeters) {
                                            busStopInLine[i].distanceInMeters !=
                                                    0
                                                ? nearest = i
                                                : nearest = nearest;
                                          }
                                        }
                                        return Obx(() => ListTile(
                                              tileColor:
                                                  selectedBusStopIndex.value ==
                                                          busStopList.indexOf(
                                                              busStopInLine[
                                                                  indexInLine])
                                                      ? AppColors.lightBlue
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    nearest == indexInLine
                                                        ? AppColors.orange
                                                        : Colors.grey,
                                                foregroundColor: Colors.white,
                                                child: Text(busStopInLine[
                                                        indexInLine]
                                                    .line['order'][
                                                        // bus stop in line has array of line [1] or [1, 2] map with bus line list
                                                        busStopInLine[
                                                                indexInLine]
                                                            .line['line']
                                                            .indexOf(busController
                                                                    .busLineList[
                                                                index]["Id"])]
                                                    // .indexOf(busStopList[index])
                                                    .toString()),
                                              ),
                                              title: Text(
                                                busStopInLine[indexInLine].name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                  busStopInLine[indexInLine]
                                                      .address),
                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      busStopInLine[indexInLine]
                                                          .getDistance()),
                                                  Text(
                                                      busStopInLine[indexInLine]
                                                          .getDuration()),
                                                ],
                                              ),
                                              onTap: () {
                                                Get.dialog(BusInfoDialog(
                                                    busStopInLine:
                                                        busStopInLine[
                                                            indexInLine]));
                                              },
                                            ));
                                      },
                                    ),
                                  ],
                                );
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                });
              },
            );
          },
        )
        // ExpansionPanelList(
        //   expansionCallback: (int index, bool isExpanded) {
        //     // setState(() {
        //     //   busList[index].isExpanded = !isExpanded;
        //     // });
        //   },
        //   children: busList.map<ExpansionPanel>((BusModel bus) {
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
        //   itemCount: busList.length,
        //   itemBuilder: (context, index) {
        //     return Card(
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(25.0),
        //       ),
        //       child: ListTile(
        //         leading: const Icon(Icons.directions_bus),
        //         title: Text(busList[index].name),
        //         subtitle: Text(busList[index].address),
        //         trailing: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text(busList[index].getDistance()),
        //             Text(busList[index].getDuration()),
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

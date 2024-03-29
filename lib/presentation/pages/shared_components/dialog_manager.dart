import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/extensions/list_extensions.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:smart_bus/services/firebase_services.dart';

BusStopModel? previousBusStop;

class DialogManager {
  void showDialog(String title, String message) {
    // First, check if a dialog is already open. If so, close it.
    if (Get.isDialogOpen == true) {
      return;
    }

    // Then show your new dialog.
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              // Close the dialog
              Get.back();
            },
          ),
        ],
      ),
      barrierDismissible:
          false, // Set to true if you want to allow dismissing the dialog by tapping the barrier.
    );
  }

  void showSelectNextBusStopDialog(
      {BusStopModel? busStop, bool alert = false}) {
    if (Get.isDialogOpen == true || selectedBusSharingId.value == null) {
      return;
    }
    int order = 0;
    logger.i(order);

    if (previousBusStop != null) {
      order = busStopList[busStopList.indexOf(previousBusStop!)].line['order'][
          previousBusStop!.line['line']
              .indexOf(selectedBusSharingId.value!.busStopLine)];
      if (busStop!.id == previousBusStop!.id) {
        return;
      }
    }
    if (alert) {
      FlutterRingtonePlayer.playNotification(
        looping: true,
      );
    }

    // play sound
    final busStopInLine = busStopList
        .where((element) => element.line['line']
            .contains(selectedBusSharingId.value!.busStopLine))
        .toList();
    // order bus stop in line

    busStopInLine.sortBy((item) => item.line['order']
        [item.line['line'].indexOf(selectedBusSharingId.value!.busStopLine)]);

    List<BusStopModel> nextBusStopList = [];
    if (busStop != null) {
      for (int index = 0; index < busStopInLine.length; index++) {
        logger.i(busStopInLine[index].id);
        if (busStopInLine[index].id == busStop.id) {
          if (index + 1 < busStopInLine.length) {
            nextBusStopList.add(busStopInLine[index + 1]);
          }
          if (index - 1 >= 0) {
            nextBusStopList.add(busStopInLine[index - 1]);
          }
        }
      }
    } else {
      nextBusStopList = busStopInLine;
    }

    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            // show icon notification
            if (alert)
              const Icon(
                Icons.notification_important,
                color: Colors.red,
                size: 50,
              ),

            const Text(
              'Select next bus stop',
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: GridView.builder(
              itemCount: nextBusStopList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // childAspectRatio: 3,
              ),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  child: ListTile(
                    onTap: () {
                      previousBusStop = busStop;
                      final int nextStopOrder =
                          busStopList[busStopList.indexOf(busStop)]
                                  .line['order'][
                              busStopList[busStopList.indexOf(busStop)]
                                  .line['line']
                                  .indexOf(
                                      selectedBusSharingId.value!.busStopLine)];
                      logger.i("next stop order: $nextStopOrder order: $order");
                      FirebaseServices.updateBusNextStop(
                          busId: selectedBusSharingId.value!.id!,
                          nextStop: nextBusStopList[index].id,
                          onward: nextStopOrder > order ? true : false);
                      FlutterRingtonePlayer.stop();
                      Get.back();
                    },
                    title: Center(
                        child: Text(
                      nextBusStopList[index].name,
                      textAlign: TextAlign.center,
                    )),
                  ),
                );
              },
            )
                // child: ListView.builder(
                //   itemCount: nextBusStopList.length,
                //   itemBuilder: (context, index) {
                //     return ListTile(
                //       onTap: () {
                //         // selectedBusStopIndex.value = index;
                //         logger.i(nextBusStopList[index].id);
                //         FirebaseServices.updateBusNextStop(
                //             busId: selectedBusSharingId.value!.id!,
                //             nextStop: nextBusStopList[index].id);
                //         FlutterRingtonePlayer.stop();
                //         Get.back();
                //       },
                //       title: Text(nextBusStopList[index].name),
                //     );
                //   },
                // ),
                ),
            ExpansionTile(title: const Text('More'), children: [
              ...busStopInLine.map(
                (e) => ListTile(
                  onTap: () {
                    // selectedBusStopIndex.value = index;
                    Get.back();
                  },
                  title: Text(e.name),
                ),
              )
            ]),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                FlutterRingtonePlayer.stop();
                Get.back();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

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
    if (alert) {
      FlutterRingtonePlayer.playNotification();
    }

    // play sound
    final busStopInLine = busStopList
        .where((element) => element.line['line']
            .contains(selectedBusSharingId.value!.busStopLine))
        .toList();
    List<BusStopModel> nextBusStopList = [];
    if (busStop != null) {
      for (int index = 0; index < busStopInLine.length; index++) {
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
              child: ListView.builder(
                itemCount: nextBusStopList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      // selectedBusStopIndex.value = index;
                      FlutterRingtonePlayer.stop();
                      Get.back();
                    },
                    title: Text(nextBusStopList[index].name),
                  );
                },
              ),
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

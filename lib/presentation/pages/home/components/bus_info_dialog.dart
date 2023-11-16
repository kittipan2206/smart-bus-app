import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/services/firebase_services.dart';

class BusInfoDialog extends StatelessWidget {
  const BusInfoDialog({super.key, required this.busStopInLine});
  final BusStopModel busStopInLine;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AlertDialog.adaptive(
          title: const Text('Bus stop information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name: ${busStopInLine.name}",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Address: ${busStopInLine.address}",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Distance: ${busStopInLine.getDistance()}",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Duration: ${busStopInLine.getDuration()}",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: FilledButton(
                    style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all<Size>(const Size(200, 50)),
                      backgroundColor: selectedBusStopIndex.value ==
                              busStopList.indexOf(busStopInLine)
                          ? MaterialStateProperty.all<Color>(
                              AppColors.red.withOpacity(0.5))
                          : MaterialStateProperty.all<Color>(AppColors.orange),
                    ),
                    onPressed: () {
                      selectedBusStopIndex.value ==
                              busStopList.indexOf(busStopInLine)
                          ? selectedBusStopIndex.value = -1
                          : selectedBusStopIndex.value =
                              busStopList.indexOf(busStopInLine);
                      logger.i(busStopInLine.id);
                      FirebaseServices.addHistory(busStop: busStopInLine);
                      Get.back();
                    },
                    child: Text(
                      selectedBusStopIndex.value ==
                              busStopList.indexOf(busStopInLine)
                          ? "Unfollow"
                          : "Follow",
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
              FilledButton(
                onPressed: () {
                  MapsLauncher.launchCoordinates(
                    busStopInLine.location.latitude,
                    busStopInLine.location.longitude,
                  );
                  // MapsLauncher.createCoordinatesUri(
                  //     busStopInLine[index].location
                  //         .latitude,
                  //     busStopInLine[index].location
                  //         .longitude);
                  // MapsLauncher.launchQuery(
                  //     busStopInLine[index].name);
                },
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions),
                      Text("Navigate to this bus"),
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
        ));
  }
}

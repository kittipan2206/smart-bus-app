import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/bus_detail_page.dart';
import 'package:smart_bus/services/firebase_services.dart';
import 'package:smart_bus/utils/unit.dart';

class SelectedBusStopWidget extends StatelessWidget {
  const SelectedBusStopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => StreamBuilder<List<BusModel>>(
          stream: FirebaseServices.getStreamBusByLines(
              busStopList[selectedBusStopIndex.value].line['line']),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No data'),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   'Selected Bus Stop',
                //   style: TextStyle(
                //     fontSize: 20.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                const SizedBox(height: 10.0),
                _buildBusStopCard(snapshot.data!),
              ],
            );
          },
        ));
  }

  Widget _buildBusStopCard(List<BusModel> busList) {
    return Obx(
      () {
        // sort by duration time and status must be true
        busList.sort((a, b) {
          final busStopInLine = busStopList
              .where((element) =>
                  element.line['line'].contains(a.busStopLine) &&
                  element.line['line'].contains(b.busStopLine))
              .toList();
          final durationTimeA = a.matrix != null
              ? a.matrix!['duration'][busStopInLine
                  .indexOf(busStopList[selectedBusStopIndex.value])]
              : 0;
          final durationTimeB = b.matrix != null
              ? b.matrix!['duration'][busStopInLine
                  .indexOf(busStopList[selectedBusStopIndex.value])]
              : 0;
          if (durationTimeA == 0) {
            return 1;
          }
          if (durationTimeB == 0) {
            return -1;
          }
          if (a.status != true || a.status == null) {
            return 1;
          }
          if (b.status != true || b.status == null) {
            return -1;
          }
          return durationTimeA.compareTo(durationTimeB);
        });
        final BusStopModel busStop = busStopList[selectedBusStopIndex.value];
        return Container(
          margin: const EdgeInsets.only(top: 20.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRowWithIcon(Icons.stop, 'Bus Stop Name', busStop.name),
              const SizedBox(height: 10.0),
              _buildRowWithIcon(Icons.social_distance, 'Bus stop distance',
                  busStop.getDistance()),
              const SizedBox(height: 10.0),
              _buildRowWithIcon(
                  Icons.timer, 'Bus stop duration', busStop.getDuration()),
              const SizedBox(height: 10.0),
              _buildRowWithIcon(
                  Icons.location_on, 'Bus stop address', busStop.address),
              const SizedBox(height: 10.0),
              _buildRowWithIcon(Icons.line_style, 'Bus stop line',
                  busStop.line['line'].join(', ')),
              const SizedBox(height: 10.0),
              const Text(
                'Buses',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...busList.map((bus) {
                final int order =
                    busStopList[selectedBusStopIndex.value].line['order'][
                            busStopList[selectedBusStopIndex.value]
                                .line['line']
                                .indexOf(bus.busStopLine)] -
                        1;
                final nextBus = busStopList.firstWhereOrNull(
                    (element) => element.id == bus.nextBusStop);
                bool passed = false;
                if (nextBus != null) {
                  // return const SizedBox();
                  final nextBusStopIndex = busStopList.indexOf(nextBus);
                  // logger.d(indexOfNextBus);
                  final nextStopOrder =
                      busStopList[nextBusStopIndex].line['order'][
                              busStopList[nextBusStopIndex]
                                  .line['line']
                                  .indexOf(bus.busStopLine)] -
                          1;

                  if (bus.onward == true || bus.onward == null) {
                    passed = order < nextStopOrder;
                  } else {
                    passed = order > nextStopOrder;
                  }
                }

                final durationTime = bus.matrix != null
                    ? UnitUtils.formatDuration(
                        duration: bus.matrix!['duration'][order],
                        passed: passed)
                    : 'N/A';
                return ListTile(
                  onTap: () {
                    Get.to(() => BusDetailPage(bus: bus));
                  },
                  trailing: Text(
                    bus.status ?? false ? durationTime : 'N/A',
                    style: TextStyle(
                      fontSize: 16.0,
                      color:
                          bus.status ?? false ? AppColors.orange : Colors.grey,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  tileColor: Colors.grey.withOpacity(0.2),
                  leading: CircleAvatar(
                    backgroundColor: bus.status ?? false
                        ? AppColors.orange
                        : Colors.grey[300],
                    child: Text(
                      bus.name!.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    bus.name!,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color:
                          bus.status ?? false ? AppColors.black : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRowWithIcon(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.orange, size: 20.0),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

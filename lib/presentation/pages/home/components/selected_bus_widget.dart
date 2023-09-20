import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/bus_detail_page.dart';

class SelectedBusStopWidget extends StatelessWidget {
  const SelectedBusStopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final BusStopModel busStop = busStopList[selectedBusStopIndex.value];
      final List<BusModel> buses = busList.where((bus) {
        return busStop.line['line'].contains(bus.busStopLine);
      }).toList();

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
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildRowWithIcon(Icons.stop, 'Bus Stop Name', busStop.name),
            SizedBox(height: 10.0),
            _buildRowWithIcon(Icons.social_distance, 'Bus stop distance',
                busStop.getDistance()),
            SizedBox(height: 10.0),
            _buildRowWithIcon(
                Icons.timer, 'Bus stop duration', busStop.getDuration()),
            SizedBox(height: 10.0),
            _buildRowWithIcon(
                Icons.location_on, 'Bus stop address', busStop.address),
            SizedBox(height: 10.0),
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
            ...buses.map((bus) {
              return ListTile(
                onTap: () {
                  Get.to(() => BusDetailPage(busIndex: busList.indexOf(bus)));
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.orange,
                  size: 20.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                tileColor: Colors.grey.withOpacity(0.2),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.orange,
                  child: Icon(
                    Icons.directions_bus,
                    color: AppColors.white,
                    size: 20.0,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bus.name!,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Text(
                    //   busStop.getDistance(),
                    //   style: TextStyle(
                    //     fontSize: 16.0,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildRowWithIcon(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.orange, size: 20.0),
            SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(width: 10.0),
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

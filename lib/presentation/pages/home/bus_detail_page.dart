import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';

class BusDetailPage extends StatelessWidget {
  BusDetailPage({Key? key, required this.busIndex}) : super(key: key);
  final int busIndex;

  final RxBool isFavorite = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bus = busList[busIndex];
      return Scaffold(
        appBar: AppBar(
          title: Text(bus.name!),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite.value ? Icons.star : Icons.star_border,
              ),
              onPressed: () => isFavorite.value = !isFavorite.value,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              _buildDetailCard('Bus Name', bus.name!),
              _buildDetailCard('License Plate', bus.licensePlate!),
              _buildDetailCard('Status', bus.status! ? 'Active' : 'Inactive',
                  textColor: bus.status! ? Colors.green : Colors.red),
              _buildDetailCard('Next Bus Stop', bus.nextBusStop!),
              _buildDetailCard('Onward', bus.onward! ? 'Yes' : 'No',
                  textColor: bus.onward! ? Colors.green : Colors.red),
              _buildDetailCard('Owner', bus.owner!),
              _buildDetailCard('Bus Stop Line', bus.busStopLine!.toString()),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: AppColors.lightBlue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Navigate to community page or show community details
              },
              icon: const Icon(Icons.people),
              label: const Text("Community"),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDetailCard(String title, String value, {Color? textColor}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

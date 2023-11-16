import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/model/history_model.dart';
import 'package:smart_bus/services/firebase_services.dart';

import 'bus_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Page'),
      ),
      body: StreamBuilder<List<HistoryModel>>(
        stream: FirebaseServices.getStreamHistoryData(),
        builder: (context, snapshot) {
          logger.d(snapshot.data);
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
          snapshot.data!.sort((a, b) => b.time.compareTo(a.time));
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final history = snapshot.data![index];
              return ListTile(
                // ex. 12 pm or 12 am o
                leading:
                    Text(history.time.toDate().toString().substring(0, 16)),
                title: Text(history.busStop.name),
                // subtitle: Text(history.time),
                // onTap: () {
                //   Get.to(
                //     () => BusDetailPage(
                //       bus: BusModel(
                //         id: history.busId,
                //         name: history.busName,
                //         status: history.busStatus,
                //         time: history.time,
                //       ),
                //     ),
                //   );
                // },
              );
            },
          );
        },
      ),
    );
  }
}

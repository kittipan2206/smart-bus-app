import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_info_dialog.dart';
import 'package:smart_bus/services/firebase_services.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Page'),
      ),
      body: StreamBuilder<List<BusStopModel>?>(
        stream: FirebaseServices.getFavoriteBusStop(),
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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final busStop = snapshot.data![index];

              return ListTile(
                title: Text(busStop.name),
                subtitle: Text(busStop.address),
                onTap: () {
                  Get.dialog(BusInfoDialog(
                    busStopInLine: busStop,
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

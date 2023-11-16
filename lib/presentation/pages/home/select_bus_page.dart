import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/presentation/pages/home/bus_detail_page.dart';
import 'package:smart_bus/services/firebase_services.dart';

class SelectBusPage extends StatelessWidget {
  const SelectBusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show all bus'),
      ),
      body: StreamBuilder<List<BusModel>>(
        stream: FirebaseServices.getStreamBusData(),
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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      child: Text(snapshot.data![index].name![0]),
                    ),
                    if (snapshot.data![index].status ?? false)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(snapshot.data![index].name!),
                subtitle: Text(snapshot.data![index].licensePlate!),
                onTap: () {
                  Get.to(() => BusDetailPage(
                        busIndex: index,
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
// child: ListView.builder(
//           itemCount: busList.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               leading: Stack(
//                 children: [
//                   CircleAvatar(
//                     child: Text(busList[index].name![0]),
//                   ),
//                   if (busList[index].status ?? false)
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: Container(
//                         width: 15,
//                         height: 15,
//                         decoration: BoxDecoration(
//                           color: Colors.green,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               title: Text(busList[index].name!),
//               subtitle: Text(busList[index].licensePlate!),
//               onTap: () {
//                 Get.to(() => BusDetailPage(
//                       busIndex: index,
//                     ));
//               },
//             );
//           },
//         ),
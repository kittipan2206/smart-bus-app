import 'package:flutter/material.dart';
import 'package:smart_bus/globals.dart';

class BusList extends StatelessWidget {
  const BusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Bus stop spots near you",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: busList.value.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.directions_bus),
                title: Text(busList.value[index].name),
                subtitle: Text(busList.value[index].address),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(busList.value[index].getDistance()),
                    Text(busList.value[index].getDuration()),
                  ],
                ),
                onTap: () {},
              ),
            );
          },
        ),
      ],
    );
  }
}

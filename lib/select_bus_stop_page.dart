import 'dart:async';

import 'package:flutter/material.dart';

import 'busModel.dart';
import 'globals.dart';
import 'home_page.dart';

class SelectBusStopPage extends StatefulWidget {
  const SelectBusStopPage({super.key});

  @override
  _SelectBusStopPageState createState() => _SelectBusStopPageState();
}

class _SelectBusStopPageState extends State<SelectBusStopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              selectedBusIndex = 0;
              if (busStreamController.isClosed) {
                busStreamController = StreamController<Bus>();
              }
              busStreamController.add(busList[0]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
              );
            },
            // rectangular button with rounded corners
            isExtended: true,
            label: const Text('Find nearest bus stop')),
        appBar: AppBar(
          title: const Text('Select Bus Stop'),
        ),
        body: Column(
          children: [
            ExpansionTile(
                title: const Text('Line 1',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  for (var i = 0; i < busList.length; i++)
                    // if (busList[i].busNumber == '1')
                    ListTile(
                      title: Text(busList[i].name),
                      onTap: () {
                        selectedBusIndex = i;
                        if (busStreamController.isClosed) {
                          busStreamController = StreamController<Bus>();
                        }
                        busStreamController.add(busList[i]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyHomePage(),
                          ),
                        );
                      },
                    )
                ]),
          ],
        ));
  }
}

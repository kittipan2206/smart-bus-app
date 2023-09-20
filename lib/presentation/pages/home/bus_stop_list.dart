import 'package:flutter/material.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_list.dart';

class BusStopListPage extends StatelessWidget {
  const BusStopListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Stop List'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: BusList(),
        ),
      ),
    );
  }
}

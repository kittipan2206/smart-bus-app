import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_info_dialog.dart';

class JourneyPlanPage extends StatefulWidget {
  const JourneyPlanPage({Key? key}) : super(key: key);

  @override
  State<JourneyPlanPage> createState() => _JourneyPlanPageState();
}

class _JourneyPlanPageState extends State<JourneyPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final startController = TextEditingController();
  final endController = TextEditingController();
  List<BusStopModel> resultPath = [];
  @override
  void initState() {
    super.initState();
    // Adjacent stops and the "cost" (for this example, it's 1 for every stop)
    for (var stop in busStopList) {
      for (var i = 0; i < stop.line['line'].length; i++) {
        // find by line and before or after of order
        final adjacents = busStopList.where((element2) {
          return element2.line['line'].contains(stop.line['line'][i]) &&
              (element2.line['order'].contains(stop.line['order'][i] - 1) ||
                  element2.line['order'].contains(stop.line['order'][i] + 1));
        });
        // add adjacent stops to adjacentStops
        stop.adjacentStops.addAll({
          for (var adjacent in adjacents)
            adjacent: 1 // for this example, it's 1 for every stop
        });
      }
    }
  }

  // Mockup suggestion function for autocomplete
  Future<List<BusStopModel>> getSuggestions(String query) async {
    List<BusStopModel> busStops = busStopList;
    return busStops
        .where((loc) =>
            loc.name.toLowerCase().contains(query.toLowerCase()) ||
            loc.address.toLowerCase().contains(query.toLowerCase()) ||
            loc.line.toString().contains(query.toLowerCase()))
        .map((e) {
      return e;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        Container(
                          height: 50,
                          width: 1,
                          color: Colors.grey,
                        ),
                        Icon(Icons.location_on, color: Colors.red),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: startController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            return await getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.name),
                              subtitle: Text(suggestion.address),
                              trailing: IconButton(
                                onPressed: () {
                                  Get.dialog(
                                    BusInfoDialog(busStopInLine: suggestion),
                                  );
                                },
                                icon:
                                    const Icon(Icons.info, color: Colors.blue),
                              ),
                              leading: Text(
                                suggestion.line['line'].join(', '),
                                style: const TextStyle(color: Colors.blue),
                              ),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              startController.text = suggestion.name;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter start location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            //
                            controller: endController,
                            decoration: const InputDecoration(
                              labelText: 'Destination',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            return await getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.name),
                              subtitle: Text(suggestion.address),
                              trailing: IconButton(
                                onPressed: () {
                                  Get.dialog(
                                    BusInfoDialog(busStopInLine: suggestion),
                                  );
                                },
                                icon:
                                    const Icon(Icons.info, color: Colors.blue),
                              ),
                              leading: Text(
                                suggestion.line['line'].join(', '),
                                style: const TextStyle(color: Colors.blue),
                              ),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              endController.text = suggestion.name;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter end location';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  // nearest bus stop button
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          nearestBusStop = busStopList.first;
                          Fluttertoast.showToast(
                              msg:
                                  'Nearest bus stop is ${nearestBusStop!.name}');
                          startController.text = nearestBusStop!.name;
                        },
                        icon: const Icon(Icons.near_me, color: Colors.blue),
                      ),
                      Container(
                        height: 20,
                      ),
                      IconButton(
                          onPressed: () {
                            final temp = startController.text;
                            startController.text = endController.text;
                            endController.text = temp;
                          },
                          icon: const Icon(Icons.swap_vert, color: Colors.red)),
                    ],
                  ),
                ],
              ),
              if (startController.text.isNotEmpty &&
                  endController.text.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // unfocus keyboard
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          resultPath = findShortestRoute(
                              busStopList.firstWhere((element) =>
                                  element.name == startController.text),
                              busStopList.firstWhere((element) =>
                                  element.name == endController.text));
                          Fluttertoast.showToast(
                              msg: 'Shortest path: ${resultPath.length} stops');

                          setState(() {});
                        }
                      },
                      child: Text('Search'),
                    ),
                  ],
                ),
              if (resultPath.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: resultPath.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Get.dialog(
                            BusInfoDialog(busStopInLine: resultPath[index]),
                          );
                        },
                        title: Text(resultPath[index].name),
                        subtitle: Text(resultPath[index].address),
                        leading: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            resultPath[index].line['line'].join('to '),
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (resultPath.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No result'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<BusStopModel> findShortestRoute(
      BusStopModel start, BusStopModel destination) {
    Map<BusStopModel, int> shortestDistance = {};
    Map<BusStopModel, BusStopModel?> previousStop = {};
    List<BusStopModel> unvisited = [];
    BusStopModel? currentStop = start;

    // Initialize distances and previous stops
    for (var stop in busStopList) {
      shortestDistance[stop] = 999999999;
      previousStop[stop] = null;
      unvisited.add(stop);
    }
    shortestDistance[start] = 0;

    while (unvisited.isNotEmpty && currentStop != null) {
      // Get the adjacent stops of the current stop
      for (var entry in currentStop.adjacentStops.entries) {
        var adjacent = entry.key;
        var weight = entry.value;

        // Calculate tentative distance to the neighboring stop
        var tentativeDistance = shortestDistance[currentStop]! + weight;

        if (tentativeDistance < shortestDistance[adjacent]!) {
          shortestDistance[adjacent] = tentativeDistance;
          previousStop[adjacent] = currentStop;
        }
      }

      // Remove the current stop from unvisited
      unvisited.remove(currentStop);

      // Select the unvisited stop with the shortest tentative distance
      if (unvisited.isNotEmpty) {
        currentStop = unvisited.reduce(
            (a, b) => shortestDistance[a]! < shortestDistance[b]! ? a : b);
      } else {
        currentStop = null;
      }
    }

    // Reconstruct the path
    List<BusStopModel> path = [];
    BusStopModel? tempStop = destination;
    while (tempStop != null) {
      path.insert(0, tempStop);
      if (previousStop[tempStop] != null) {
        tempStop = previousStop[tempStop];
      } else {
        break;
      }
    }

    return path;
  }
}

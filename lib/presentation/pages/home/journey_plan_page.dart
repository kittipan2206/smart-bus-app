import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_stop_model.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_info_dialog.dart';
import 'package:smart_bus/presentation/pages/home/controller/bus_controller.dart';

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
  bool isLoding = false;

  @override
  void initState() {
    super.initState();
    // Adjacent stops and the "cost" (for this example, it's 1 for every stop)

    getAdjacentStops();
  }

  void getAdjacentStops() {
    setState(() {
      isLoding = true;
    });
    for (var stop in busStopList) {
      for (var i = 0; i < stop.line['line'].length; i++) {
        // find by line and before or after of order
        final adjacents = busStopList.where((element) {
          if (element.line['line'].contains(stop.line['line'][i])) {
            if (element.line['order']
                        [element.line['line'].indexOf(stop.line['line'][i])] ==
                    stop.line['order'][i] - 1 ||
                element.line['order']
                        [element.line['line'].indexOf(stop.line['line'][i])] ==
                    stop.line['order'][i] + 1) {
              return true;
            }
          }
          return false;
        });
        // add adjacent stops to adjacentStops
        stop.adjacentStops.addAll({
          for (var adjacent in adjacents)
            adjacent: 1 // for this example, it's 1 for every stop
        });
      }
    }
    setState(() {
      isLoding = false;
    });
  }

  // Mockup suggestion function for autocomplete
  Future<List<dynamic>> getSuggestions(String query) async {
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
    final BusController busController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Plan'),
      ),
      body: isLoding
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.blue),
                                Container(
                                  height: 50,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                const Icon(Icons.location_on,
                                    color: Colors.red),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                TypeAheadFormField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: startController,
                                    decoration: const InputDecoration(
                                      labelText: 'Starting point',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  suggestionsBoxDecoration:
                                      SuggestionsBoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    return await getSuggestions(pattern);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion.name),
                                      subtitle: Text(suggestion.address),
                                      leading: Text(
                                        suggestion.line['line'].join(', '),
                                        style:
                                            const TextStyle(color: Colors.blue),
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
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: endController,
                                    decoration: const InputDecoration(
                                      labelText: 'Destination',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  suggestionsBoxDecoration:
                                      SuggestionsBoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    return await getSuggestions(pattern);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion.name),
                                      subtitle: Text(suggestion.address),
                                      leading: Text(
                                        suggestion.line['line'].join(', '),
                                        style:
                                            const TextStyle(color: Colors.blue),
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
                                icon: const Icon(Icons.near_me,
                                    color: Colors.blue),
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
                                  icon: const Icon(Icons.swap_vert,
                                      color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                      if (startController.text.isNotEmpty &&
                          endController.text.isNotEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(100, 50),
                                  ),
                                  onPressed: () {
                                    // unfocus keyboard
                                    FocusScope.of(context).unfocus();
                                    if (_formKey.currentState!.validate()) {
                                      resultPath = findShortestRoute(
                                          busStopList.firstWhere((element) =>
                                              element.name ==
                                              startController.text),
                                          busStopList.firstWhere((element) =>
                                              element.name ==
                                              endController.text));
                                      Fluttertoast.showToast(
                                          msg:
                                              'Shortest path: ${resultPath.length} stops');

                                      setState(() {});
                                    }
                                  },
                                  child: const Text('Search'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (resultPath.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              'Shortest path: ${resultPath.length} stops',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'From ${resultPath.first.name} to ${resultPath.last.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Text(
                                  'Bus stops line',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Detail',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Card(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: resultPath.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        // isThreeLine: true,
                                        onTap: () {
                                          Get.dialog(
                                            BusInfoDialog(
                                                busStopInLine:
                                                    resultPath[index]),
                                          );
                                        },
                                        title: Text(resultPath[index].name),
                                        subtitle:
                                            Text(resultPath[index].address),
                                        leading: Column(
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                for (var line
                                                    in resultPath[index]
                                                        .line['line'])
                                                  Obx(() => Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            BoxDecoration(
                                                          // code color blue is 0xff3f51b5, red is 0xffe53935, green is 0xff43a047, pink is 0xffe91e63, orange is 0xffff9800
                                                          color: Color(busController
                                                                  .busLineList
                                                                  .where((element) =>
                                                                      element[
                                                                          'Id'] ==
                                                                      line)
                                                                  .first['color'] ??
                                                              0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Text(
                                                          // join line and route
                                                          line.toString(),
                                                          style: const TextStyle(
                                                              color: AppColors
                                                                  .white),
                                                        ),
                                                      )),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            if (index < resultPath.length - 1)
                                              Icon(
                                                Icons.arrow_downward,
                                                color: Color(busController
                                                        .busLineList
                                                        .where((element) =>
                                                            element['Id'] ==
                                                            resultPath[
                                                                    index + 1]
                                                                .line['line']
                                                                .first)
                                                        .first['color'] ??
                                                    0),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (index < resultPath.length - 1 &&
                                          index > 0)
                                        if (resultPath[index]
                                                    .line['line']
                                                    .length >
                                                1 &&
                                            (resultPath[index - 1]
                                                    .line['line']
                                                    .join(' to ') !=
                                                resultPath[index + 1]
                                                    .line['line']
                                                    .join(' to ')))
                                          Container(
                                            color: AppColors.orange,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Change to',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      resultPath[index + 1]
                                                          .name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    // show only line that related between previous stop and next stop such as previous stop is 1, next stop is 1, 2 then show only line 1
                                                    for (var line
                                                        in resultPath[index + 1]
                                                            .line['line'])
                                                      if (resultPath[index]
                                                          .line['line']
                                                          .contains(line))
                                                        Obx(
                                                          () => Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            decoration:
                                                                BoxDecoration(
                                                              // code color blue is 0xff3f51b5, red is 0xffe53935, green is 0xff43a047, pink is 0xffe91e63, orange is 0xffff9800
                                                              color: Color(busController
                                                                      .busLineList
                                                                      .where((element) =>
                                                                          element[
                                                                              'Id'] ==
                                                                          line)
                                                                      .first['color'] ??
                                                                  0),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                              // join line and route
                                                              line.toString(),
                                                              style: const TextStyle(
                                                                  color: AppColors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      if (resultPath.isEmpty)
                        const Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'No result',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 600),
                          ],
                        ),
                    ],
                  ),
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

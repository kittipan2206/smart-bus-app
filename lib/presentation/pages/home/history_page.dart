import 'package:flutter/material.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/history_model.dart';
import 'package:smart_bus/services/firebase_services.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Page'),
      ),
      body: !isLogin.value
          ? const Center(
              child: Text('Please login to use this feature'),
            )
          : StreamBuilder<List<HistoryModel>>(
              stream: FirebaseServices.getStreamHistoryData(),
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
                snapshot.data!.sort((a, b) => b.time.compareTo(a.time));
                // final todayList = snapshot.data!
                //     .where((element) =>
                //         element.time.toDate().day == DateTime.now().day &&
                //         element.time.toDate().month == DateTime.now().month &&
                //         element.time.toDate().year == DateTime.now().year)
                //     .toList();
                // final formatedDate =
                //     DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final history = snapshot.data![index];

                    return ListTile(
                      // leading:
                      //     Text(history.time.toDate().toString().substring(0, 16)),
                      trailing: Text(
                          history.time.toDate().toString().substring(0, 16)),
                      title: Text(history.busStop.name),
                      subtitle: Text(history.busStop.address),
                      onTap: () {},
                    );
                  },
                );
              },
            ),
    );
  }
}

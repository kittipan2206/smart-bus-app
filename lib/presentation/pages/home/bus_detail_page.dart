import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smart_bus/model/review_model.dart';
import 'package:smart_bus/services/firebase_services.dart';

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
              _buildDetailCard(
                  'Status', bus.status ?? false ? 'Active' : 'Inactive',
                  textColor: bus.status ?? false ? Colors.green : Colors.red),
              _buildDetailCard('Next Bus Stop', bus.nextBusStop ?? "No data"),
              _buildDetailCard('Onward', bus.onward ?? true ? 'Yes' : 'No',
                  textColor: bus.onward ?? true ? Colors.green : Colors.red),
              _buildDetailCard('Owner', bus.owner!),
              _buildDetailCard('Bus Stop Line', bus.busStopLine!.toString()),
              buildReviewsSection(),
              buildReviewInput(),
            ],
          ),
        ),
        // bottomNavigationBar: Container(
        //   color: AppColors.lightBlue,
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //     child: ElevatedButton.icon(
        //       style: ElevatedButton.styleFrom(
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(30),
        //         ),
        //       ),
        //       onPressed: () {
        //         // Navigate to community page or show community details
        //       },
        //       icon: const Icon(Icons.people),
        //       label: const Text("Community"),
        //     ),
        //   ),
        // ),
      );
    });
  }

  Widget _buildDetailCard(String title, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
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
    );
  }

  Widget buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        StreamBuilder<List<ReviewModel>>(
          stream: FirebaseServices.getReviews(busList[busIndex].id!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final reviews = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                logger.i(review);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(review.user.avatarUrl),
                    ),
                    title: Text(review.user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.createdAt.toIso8601String().split('T')[0],
                        ),
                        RatingBar.builder(
                          itemSize: 20,
                          initialRating: review.rating.toDouble(),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return const Icon(Icons.star, color: Colors.amber);
                          },
                          onRatingUpdate: (rating) {},
                        ),
                        Text(review.content),
                      ],
                    ),
                    trailing: review.user.id ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final TextEditingController controller =
                                      TextEditingController(
                                          text: review.content);
                                  double _rating = review.rating.toDouble();
                                  return AlertDialog(
                                    title: const Text('Edit Review'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                              hintText: 'Write a review'),
                                        ),
                                        RatingBar.builder(
                                          initialRating: _rating,
                                          itemCount: 5,
                                          itemBuilder: (context, index) {
                                            return const Icon(Icons.star,
                                                color: Colors.amber);
                                          },
                                          onRatingUpdate: (rating) {
                                            _rating = rating;
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      // delete button
                                      TextButton(
                                        onPressed: () {
                                          // confirm delete
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Delete'),
                                                content: const Text(
                                                    'Are you sure you want to delete this review?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      FirebaseFirestore.instance
                                                          .collection('reviews')
                                                          .doc(review.id)
                                                          .delete();
                                                      Get.back();
                                                      Get.back();
                                                    },
                                                    child: const Text('Yes'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('reviews')
                                              .doc(review.id)
                                              .update({
                                            'content': controller.text,
                                            'rating': _rating.toInt(),
                                          });
                                          controller.clear();
                                          Get.back();
                                        },
                                        child: const Text('Edit'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget buildReviewInput() {
    TextEditingController controller = TextEditingController();
    double _rating = 5; // Default rating
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Write a review'),
        ),
        RatingBar.builder(
          initialRating: _rating,
          itemCount: 5,
          itemBuilder: (context, index) {
            return const Icon(Icons.star, color: Colors.amber);
          },
          onRatingUpdate: (rating) {
            _rating = rating;
          },
        ),
        ElevatedButton(
          onPressed: () {
            final newReview = ReviewModel(
              id: '',
              user: UserModel(
                id: user!.uid,
                name: user.displayName!,
                avatarUrl: user.photoURL!,
              ),
              content: controller.text,
              createdAt: DateTime.now(),
              rating: _rating.toInt(),
              busId: busList[busIndex].id!,
            );
            FirebaseFirestore.instance
                .collection('reviews')
                .add(newReview.toJson())
                .then((value) {
              FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(value.id)
                  .update({'id': value.id});
            });
            controller.clear();
          },
          child: const Text('Submit Review'),
        ),
      ],
    );
  }
}

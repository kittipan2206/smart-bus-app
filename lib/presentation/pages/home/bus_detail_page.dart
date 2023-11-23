import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/globals.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smart_bus/model/bus_model.dart';
import 'package:smart_bus/model/review_model.dart';
import 'package:smart_bus/services/firebase_services.dart';

class BusDetailPage extends StatelessWidget {
  BusDetailPage({Key? key, required this.bus}) : super(key: key);
  final BusModel bus;

  final RxBool isFavorite = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              _buildDetailCard('Bus Stop Line', bus.busStopLine!.toString()),
              _buildDetailCard('Owner', bus.id!),
              buildReviewsSection(),
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
        // show average rating

        const SizedBox(height: 20),
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        StreamBuilder<double?>(
          stream: FirebaseServices.getAverageRating(bus.id!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final averageRating = snapshot.data!;
            if (averageRating == 0) {
              return const SizedBox();
            }

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'out of 5',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RatingBar.builder(
                    itemSize: 25,
                    ignoreGestures: true,
                    initialRating: averageRating,
                    allowHalfRating: true,
                    unratedColor: Colors.amber.withAlpha(50),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const Icon(Icons.star, color: Colors.amber);
                    },
                    onRatingUpdate: (rating) {},
                  ),
                ],
              ),
            );
          },
        ),

        StreamBuilder<List<ReviewModel>>(
          stream: FirebaseServices.getReviews(bus.id!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final reviews = snapshot.data!;
            final reviewed = FirebaseAuth.instance.currentUser != null &&
                reviews
                    .where((review) =>
                        review.user.id ==
                        FirebaseAuth.instance.currentUser!.uid)
                    .isNotEmpty;

            final ReviewModel? userReview = reviews.firstWhereOrNull((review) =>
                FirebaseAuth.instance.currentUser != null &&
                review.user.id == FirebaseAuth.instance.currentUser!.uid);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!reviewed || userReview == null)
                  if (FirebaseAuth.instance.currentUser != null)
                    ExpansionTile(
                        title: const Text('Write a Review'),
                        children: [
                          buildReviewInput(),
                        ]),
                if (reviewed && userReview != null)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: FirebaseAuth.instance.currentUser!.photoURL ==
                              null
                          ? const Icon(Icons.person)
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!),
                            ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final TextEditingController controller =
                                  TextEditingController(
                                      text: userReview.content);
                              double _rating = userReview.rating.toDouble();
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
                                      unratedColor: Colors.amber.withAlpha(50),
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
                                            title: const Text('Confirm Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete this review?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('reviews')
                                                      .doc(userReview.id)
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
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('reviews')
                                          .doc(userReview.id)
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
                      ),
                      title: Text(
                          FirebaseAuth.instance.currentUser!.displayName ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userReview.createdAt
                                .toLocal()
                                .toString()
                                .substring(0, 16),
                          ),
                          RatingBar.builder(
                            itemSize: 20,
                            ignoreGestures: true,
                            initialRating: userReview.rating.toDouble(),
                            unratedColor: Colors.amber.withAlpha(50),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return const Icon(Icons.star,
                                  color: Colors.amber);
                            },
                            onRatingUpdate: (rating) {},
                          ),
                          Text(userReview.content),
                        ],
                      ),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    if (review.user.id ==
                        FirebaseAuth.instance.currentUser?.uid) {
                      return const SizedBox();
                    }
                    return Card(
                      child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                Image.network(review.user.avatarUrl,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                              return const Icon(Icons.person);
                            }).image,
                          ),
                          title: Text(review.user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // 2023-08-21 13:12
                                review.createdAt
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16),
                              ),
                              RatingBar.builder(
                                itemSize: 20,
                                ignoreGestures: true,
                                initialRating: review.rating.toDouble(),
                                unratedColor: Colors.amber.withAlpha(50),
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return const Icon(Icons.star,
                                      color: Colors.amber);
                                },
                                onRatingUpdate: (rating) {},
                              ),
                              Text(review.content),
                            ],
                          )),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildReviewInput() {
    TextEditingController controller = TextEditingController();
    double _rating = 3; // Default rating
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'Write a review (Optional)'),
        ),
        Row(
          children: [
            const Text('Rating: '),
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
          ],
        ),
        ElevatedButton(
          onPressed: () {
            final newReview = ReviewModel(
              id: '',
              user: UserModel(
                  id: user!.uid,
                  name: user.displayName!,
                  avatarUrl: user.photoURL ?? "No image"),
              content: controller.text,
              createdAt: DateTime.now(),
              rating: _rating.toInt(),
              busId: bus.id!,
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
          child: const Text('Submit Your Review'),
        ),
      ],
    );
  }
}

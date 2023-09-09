import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/pages/authen/login_page.dart';
import 'package:smart_bus/presentation/pages/home/components/bus_list.dart';
import 'package:smart_bus/presentation/pages/home/components/button.dart';
import 'package:smart_bus/presentation/pages/home/components/courosel.dart';
import 'package:smart_bus/presentation/pages/home/components/group_of_buttons.dart';
import 'package:smart_bus/presentation/pages/home/components/profile_image.dart';
import 'package:smart_bus/presentation/pages/home/journey_plan_page.dart';

class HomeBody extends StatelessWidget {
  HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    // list of names and their icons
    final List<String> names = [
      'Bus',
      'Journey plan',
      'History',
      'Profile',
    ];
    final List<IconData> icons = [
      Icons.directions_bus,
      Icons.directions,
      Icons.history,
      Icons.person,
    ];

    final List<Function()> onPresseds = [
      () {},
      () {
        Get.to(() => const JourneyPlanPage());
      },
      () {},
      () {},
    ];

    return SingleChildScrollView(
      child: Container(
        // gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 172, 229, 255),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Row(
                children: [
                  ProfileImage(),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome to Smart Bus'),
                      Text('Guest',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // carousel
              const CarouselSlidePart(),
              const SizedBox(
                height: 20,
              ),
              // Group of buttons
              GroupOfButtons(
                children: [
                  ...List.generate(
                    names.length,
                    (index) => InkWell(
                      onTap: onPresseds[index],
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.lightBlue,
                            ),
                            child: Icon(
                              icons[index],
                              color: Colors.white,
                            ),
                          ),
                          Text(names[index]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const BusList(),
            ],
          ),
        ),
      ),
    );
  }
}

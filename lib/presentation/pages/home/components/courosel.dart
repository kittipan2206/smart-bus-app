import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSlidePart extends StatelessWidget {
  const CarouselSlidePart({super.key});

  @override
  Widget build(BuildContext context) {
    final adsItem = [
      'assets/images/ads1.png',
      'assets/images/ads2.png',
      'assets/images/ads3.png',
      'assets/images/ads4.png',
    ];
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        aspectRatio: 16 / 9,
        viewportFraction: 0.85,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        // enlargeFactor: 0.05,
        // onPageChanged: callbackFunction,
        scrollDirection: Axis.horizontal,
      ),
      items: adsItem.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                ));
          },
        );
      }).toList(),
    );
  }
}

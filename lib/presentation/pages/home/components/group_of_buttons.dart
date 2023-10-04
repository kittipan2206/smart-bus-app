import 'package:flutter/material.dart';

class GroupOfButtons extends StatelessWidget {
  const GroupOfButtons({
    Key? key,
    required this.children,
    // required this.onPresseds,
  }) : super(key: key);
  // children of
  final List<Widget> children;
  // final List<Function()> onPresseds;
  @override
  Widget build(BuildContext context) {
    // Group of buttons 4 buttons in a row if more than 4 buttons, it will be next row
    return InkWell(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          children: children,
        ),
      ),
    );
  }
}

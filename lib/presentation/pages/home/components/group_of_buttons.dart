import 'package:flutter/material.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/presentation/pages/app/app.dart';

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBLue.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          children: children,
        ),
      ),
    );
  }
}

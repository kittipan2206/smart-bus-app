import 'package:flutter/material.dart';
import 'package:smart_bus/common/style/app_colors.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton(
      {Key? key, required this.icon, required this.onPressed})
      : super(key: key);
  final IconData icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.blue),
      ),
    );
  }
}

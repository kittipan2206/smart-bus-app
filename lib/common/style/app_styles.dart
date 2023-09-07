import 'package:smart_bus/common/style/app_colors.dart';
import 'package:flutter/material.dart';

class AppStyles {
  AppStyles._();

  static const String appFont = 'Poppins';

  static const bigTextStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const h1TextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  static const h2TextStyleGrey = TextStyle(
    fontSize: 16,
    color: AppColors.deepGrey,
  );

  static const h2TextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: .8,
  );

  static const normalTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: .8,
  );

  static const normalTextStyleGrey = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.deepGrey,
  );

  static const subNormalTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    letterSpacing: .8,
  );

  static const littleTextStyle = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w300,
    letterSpacing: .8,
  );

  static const littleTextStyleGrey = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w300,
    letterSpacing: .8,
    color: AppColors.deepGrey,
  );

  static const buttonTextStyle = TextStyle(
    fontSize: 16,
  );

  static const hintTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.deepGrey,
  );

  static const OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black54, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static const OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black12, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static const OutlineInputBorder errorBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 3, color: Colors.redAccent),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static const OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(color: Colors.redAccent),
  );

  static const OutlineInputBorder focusedErrorBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 3, color: Colors.redAccent),
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
  );
}

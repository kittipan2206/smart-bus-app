import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/common/style/app_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightAppTheme = ThemeData(
    fontFamilyFallback: const ['SanFrancisco'],
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: AppColors.white,
    searchBarTheme: const SearchBarThemeData(
      // 30% of primary color
      backgroundColor: MaterialStatePropertyAll(Color(0x4DCBCBCB)),
      elevation: MaterialStatePropertyAll(0),
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      )),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.blue,
      iconTheme: IconThemeData(color: AppColors.blue),
      // toolbarHeight: 67,
    ),
    dialogTheme: const DialogTheme(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.blue, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: AppStyles.enabledBorder,
      focusedBorder: AppStyles.focusedBorder,
      errorBorder: AppStyles.errorBorder,
      border: AppStyles.inputBorder,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.blue,
    ),
    fontFamily: AppStyles.appFont,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black54,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: Colors.grey, width: 2),
      ),
      dialHandColor: AppColors.blue,
      hourMinuteColor: MaterialStateColor.resolveWith(
        (Set<MaterialState> states) => states.contains(MaterialState.selected)
            ? AppColors.blue
            : Colors.black12,
      ),
      hourMinuteTextColor: MaterialStateColor.resolveWith(
        (Set<MaterialState> states) => states.contains(MaterialState.selected)
            ? Colors.black54
            : Colors.grey,
      ),
      dayPeriodBorderSide: const BorderSide(color: Colors.grey),
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      dayPeriodColor: Colors.transparent,
      dayPeriodTextColor: MaterialStateColor.resolveWith(
        (Set<MaterialState> states) => states.contains(MaterialState.selected)
            ? AppColors.blue
            : Colors.black12,
      ),
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black12),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    ),
  );
}

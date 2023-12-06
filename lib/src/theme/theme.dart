import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/colors.dart';

class GmpayWidgetTheme {
  static const borderInput = OutlineInputBorder(
      borderSide: BorderSide(color: Color(GmpayColors.primaryColor)),
      borderRadius: BorderRadius.all(Radius.circular(gap_s)));

  static final textButtonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(gap_s)));

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    visualDensity: VisualDensity.compact,
    primarySwatch: Colors.teal,
    primaryColor: Colors.teal,
    primaryTextTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: borderInput,
      contentPadding: EdgeInsets.symmetric(horizontal: gap_s, vertical: gap_m),
      isDense: true,
    ),
  );
}

//gaps sizes
const double gap_xxxs = 2.0;
const double gap_xxs = 4.0;
const double gap_xs = 8.0;
const double gap_s = 16.0;
const double gap_m = 24.0;
const double gap_l = 32.0;
const double gap_xl = 40.0;
const double gap_xxl = 48.0;
const double gap_xxxl = 56.0;
const double gap_xxxxl = 64.0;
const double gap_xxxxxl = 72.0;
const double gap_xxxxxxl = 80.0;
const double gap_xxxxxxxl = 88.0;
const double gap_xxxxxxxxl = 96.0;
const double gap_xxxxxxxxxl = 104.0;
const double gap_xxxxxxxxxxl = 112.0;
const double gap_xxxxxxxxxxxl = 120.0;
const double gap_xxxxxxxxxxxxl = 128.0;
const double gap_xxxxxxxxxxxxxl = 136.0;
const double gap_xxxxxxxxxxxxxxl = 144.0;
const double gap_xxxxxxxxxxxxxxxl = 152.0;
const double gap_xxxxxxxxxxxxxxxxl = 160.0;
const double gap_xxxxxxxxxxxxxxxxxl = 168.0;

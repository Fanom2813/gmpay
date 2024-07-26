import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/colors.dart';

class GmpayWidgetTheme {
  static const borderInput = OutlineInputBorder(
      borderSide: BorderSide(color: Color(GmpayColors.primaryColor)),
      borderRadius: BorderRadius.all(Radius.circular(gapS)));

  static final textButtonStyle = TextButton.styleFrom(
      foregroundColor: Colors.green.shade900,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40));

  static final elevatedGreenButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade900,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(gapS)));

  static final outlinedGreenButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    foregroundColor: Colors.green.shade900,
    side: BorderSide(color: Colors.green.shade900, width: 2),
  );

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
      contentPadding: EdgeInsets.symmetric(horizontal: gapS, vertical: gapM),
      isDense: true,
    ),
  );
}

//gaps sizes
const double gapXxxs = 2.0;
const double gapXxs = 4.0;
const double gapXs = 8.0;
const double gapS = 16.0;
const double gapM = 24.0;
const double gapL = 32.0;
const double gapXl = 40.0;
const double gapXxl = 48.0;
const double gapXxxl = 56.0;
const double gapXxxxl = 64.0;
const double gapXxxxxl = 72.0;
const double gapXxxxxxl = 80.0;
const double gapXxxxxxxl = 88.0;
const double gapXxxxxxxxl = 96.0;
const double gapXxxxxxxxxl = 104.0;
const double gapXxxxxxxxxxl = 112.0;
const double gapXxxxxxxxxxxl = 120.0;
const double gapXxxxxxxxxxxxl = 128.0;
const double gapXxxxxxxxxxxxxl = 136.0;
const double gapXxxxxxxxxxxxxxl = 144.0;
const double gapXxxxxxxxxxxxxxxl = 152.0;
const double gapXxxxxxxxxxxxxxxxl = 160.0;
const double gapXxxxxxxxxxxxxxxxxl = 168.0;

final shimmerColor = Colors.grey.shade300;

import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/colors.dart';

class GmpayWidgetTheme {
  static const borderInput = OutlineInputBorder(
      borderSide: BorderSide(color: Color(GmpayColors.primaryColor)),
      borderRadius: BorderRadius.all(Radius.circular(15)));

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
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
      isDense: true,
    ),
  );

  //generate text theme
  static const heading1 =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black);
  static const heading2 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black);
  static const heading3 =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black);
  static const heading4 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black);
  static const heading5 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black);
  static const heading6 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black);
  static const bodySmall =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black);
  static const bodyMedium =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black);
  static const bodyLarge =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black);
}

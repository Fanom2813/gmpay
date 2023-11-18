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
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
      isDense: true,
    ),
  );
}

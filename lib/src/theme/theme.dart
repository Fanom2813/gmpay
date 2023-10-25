import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/colors.dart';

class GmpayWidgetTheme {
  static const borderInput = OutlineInputBorder(
      borderSide: BorderSide(color: Color(GmpayColors.primaryColor)),
      borderRadius: BorderRadius.all(Radius.circular(15)));
}

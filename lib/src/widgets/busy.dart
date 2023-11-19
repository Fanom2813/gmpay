import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/text_theme.dart';

class Busy extends StatelessWidget {
  const Busy({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              color: Colors.green,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Processing Please wait ...",
            style: GmpayTextStyles.body2,
          ),
        ),
      ],
    );
  }
}

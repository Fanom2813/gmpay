import 'package:flutter/material.dart';
import 'package:gmpay/src/theme/text_theme.dart';

class Busy extends StatelessWidget {
  const Busy({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              color: Colors.green,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            message ?? "Processing Please wait ...",
            style: GmpayTextStyles.body2,
          ),
        ),
      ],
    );
  }
}

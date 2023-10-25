import 'package:flutter/material.dart';

class Busy extends StatelessWidget {
  const Busy({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 1,
          color: Colors.green,
        ),
      ),
    );
  }
}

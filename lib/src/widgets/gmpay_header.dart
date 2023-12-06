import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmpay/assets/images.dart';
import 'package:gmpay/src/widgets/bottom_sheet.dart';

class GmpayHeader extends StatelessWidget {
  const GmpayHeader({
    super.key,
    required this.navBottomSheetController,
    this.onCanceled,
  });

  final NavBottomSheetController navBottomSheetController;
  final VoidCallback? onCanceled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.memory(
              const Base64Decoder().convert(logo),
              width: 140,
            ),
            IconButton(
                onPressed: () {
                  if (onCanceled != null) {
                    onCanceled!();
                  }
                  navBottomSheetController.close();
                },
                icon: const Icon(Icons.close, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

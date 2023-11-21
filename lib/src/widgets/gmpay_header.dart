import 'package:flutter/material.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/Gmpay_logo.png",
                  package: 'gmpay',
                  width: 100,
                ),
                const Text(
                  "Be Modern, Be Green",
                  style: TextStyle(fontSize: 14),
                ),
              ],
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

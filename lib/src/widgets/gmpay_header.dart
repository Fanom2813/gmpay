import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmpay/assets/images.dart';
import 'package:gmpay/src/common/context_extension.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/bottom_sheet.dart';
import 'package:gmpay/src/widgets/merchant_info_page.dart';

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.memory(
              const Base64Decoder().convert(logo),
              width: 140,
            ),
            const Spacer(),
            context.isMobile
                ? IconButton(
                    onPressed: () {
                      context.showBottomSheet(const MerchantInfoPage());
                    },
                    icon: const Icon(Icons.help),
                    tooltip: "About your merchant",
                  )
                : TextButton.icon(
                    style: GmpayWidgetTheme.textButtonStyle,
                    onPressed: () {
                      context.showBottomSheet(const MerchantInfoPage());
                    },
                    icon: const Icon(Icons.help_outline_rounded),
                    label: const Text("Merchant Info")),
            IconButton(
              onPressed: () {
                if (onCanceled != null) {
                  onCanceled!();
                }
                navBottomSheetController.close();
              },
              icon: const Icon(Icons.close, color: Colors.black),
              tooltip: "Close payment window",
            ),
          ],
        ),
      ),
    );
  }
}

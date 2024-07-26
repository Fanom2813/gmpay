import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmpay/assets/images.dart';
import 'package:gmpay/src/common/context_extension.dart';
import 'package:gmpay/src/gmpay.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class GmpayHeader extends StatelessWidget {
  const GmpayHeader({
    super.key,
    this.onCanceled,
    this.hideInfoButton,
  });
  final VoidCallback? onCanceled;
  final bool? hideInfoButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.memory(
            const Base64Decoder().convert(logo),
            width: 140,
          ),
          const SizedBox(
            width: 20,
          ),
          if (Gmpay.instance.test == true)
            Chip(
              label: Text(
                "TEST MODE",
                style: context.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.yellow[800],
              side: BorderSide.none,
            )
        ],
      ),
    );
  }

  showInfoDiag(BuildContext context) {
    WoltModalSheet.of(context).showPageWithId("merchant_info");
  }
}

getMerchantInfoButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      WoltModalSheet.of(context).showPageWithId("merchant_info");
    },
    icon: const Icon(Icons.help),
    tooltip: "Merchant Info",
  );
}

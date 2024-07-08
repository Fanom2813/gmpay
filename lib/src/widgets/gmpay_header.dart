import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gmpay/assets/images.dart';
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
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.memory(
          const Base64Decoder().convert(logo),
          width: 140,
        ),
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

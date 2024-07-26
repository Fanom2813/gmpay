import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/app_provider.dart';
import 'package:gmpay/src/common/context_extension.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/common/mounted_state.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, this.reference});

  final String? reference;
  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends SafeState<VerificationPage>
    with SingleTickerProviderStateMixin {
  listenForCallback() async {
    Gmpay.instance.verifyTransactionTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      var resp = await Gmpay.instance.verifyTransaction(widget.reference!);

      if (resp != null) {
        setState(() {
          if (resp == TransactionStatus.success) {
            AppProvider.instance.apiResponseMessage = ApiResponseMessage(
                success: true,
                message:
                    "Congratulations, your transaction was successful 🎉🎉🎉");
          } else if (resp == TransactionStatus.failed) {
            AppProvider.instance.apiResponseMessage = ApiResponseMessage(
                success: false,
                message:
                    "Sorry, your transaction was not successful 😢, wait and try again later");
          } else {
            AppProvider.instance.apiResponseMessage = ApiResponseMessage(
                success: null, message: "Transaction in progress");
          }
        });
        timer.cancel();

        Future.delayed(const Duration(seconds: 5), () {
          closeDiag(status: resp);
        });
      }
    });
  }

  @override
  void initState() {
    if (mounted) {
      AppProvider.instance.prevPage = 'verification_page';
      listenForCallback();
    }

    super.initState();
  }

  @override
  void dispose() {
    Gmpay.instance.verifyTransactionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minHeight: 500),
      height: context.height * .4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.timer_rounded, size: 150, color: Colors.blue.shade900),
          const SizedBox(height: gapM),
          Text(
            "Please wait your transaction is being processed",
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void closeDiag({TransactionStatus? status = TransactionStatus.failed}) {
    AppProvider.instance.transactionInfo =
        TransactionInfo(reference: widget.reference, status: status);
    if (AppProvider.instance.apiResponseMessage?.success == true) {
      WoltModalSheet.of(context).showPageWithId("success_page");
    } else {
      WoltModalSheet.of(context).showPageWithId("failed_page");
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/busy.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:gmpay/src/common/mounted_state.dart';

class VerificationSheet extends StatefulWidget {
  const VerificationSheet({super.key, this.reference});

  final String? reference;
  @override
  State<VerificationSheet> createState() => _VerificationSheetState();
}

class _VerificationSheetState extends SafeState<VerificationSheet>
    with SingleTickerProviderStateMixin {
  String? working;
  ApiResponseMessage? apiResponseMessage;

  listenForCallback() async {
    setState(() {
      working = "Verifying transaction, please wait...";
    });

    Gmpay.instance.verifyTransactionTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      var resp = await Gmpay.instance.verifyTransaction(widget.reference!);

      if (resp != null) {
        setState(() {
          working = null;
          if (resp == TransactionStatus.success) {
            apiResponseMessage = ApiResponseMessage(
                success: true, message: "Transaction successful");
          } else if (resp == TransactionStatus.failed) {
            apiResponseMessage = ApiResponseMessage(
                success: false, message: "Transaction was not successful");
          } else {
            apiResponseMessage = ApiResponseMessage(
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
      listenForCallback();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: GmpayWidgetTheme.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: working != null
            ? Center(
                child: Busy(
                  message: working,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      apiResponseMessage == null ||
                              apiResponseMessage?.success == null
                          ? Icons.timer_rounded
                          : (apiResponseMessage?.success == true
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded),
                      size: 150,
                      color: apiResponseMessage == null ||
                              apiResponseMessage?.success == null
                          ? Colors.blue.shade900
                          : (apiResponseMessage?.success == true
                              ? Colors.green.shade900
                              : Colors.red.shade900)),
                  Padding(
                      padding:
                          const EdgeInsets.only(top: gap_xs, bottom: gap_m),
                      child: SectionTitle(
                          textCrossAxisAlignment: CrossAxisAlignment.center,
                          title: apiResponseMessage == null ||
                                  apiResponseMessage?.success == null
                              ? "Please wait your transaction is being processed"
                              : apiResponseMessage!.message,
                          subtitle: apiResponseMessage == null ||
                                  apiResponseMessage?.success == null
                              ? "Your transaction is being processed"
                              : (apiResponseMessage?.success == true
                                  ? "Congratulations, your transaction was successful 🎉🎉🎉"
                                  : "Sorry, your transaction was not successful 😢, wait and try again later"))),
                ],
              ),
      ),
    );
  }

  void closeDiag({TransactionStatus? status = TransactionStatus.failed}) {
    Navigator.pop(
        context, TransactionInfo(reference: widget.reference, status: status));
  }
}

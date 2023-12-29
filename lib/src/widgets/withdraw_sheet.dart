import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/socket_listener.dart';
import 'package:gmpay/src/helpers.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/busy.dart';
import 'package:gmpay/src/widgets/merchant_info_page.dart';
import 'package:gmpay/src/widgets/simple_notification_message.dart';
import 'package:gmpay/src/common/mounted_state.dart';

final formDropDown = GlobalKey<FormBuilderState>();

class WithdrawSheet extends StatefulWidget {
  const WithdrawSheet(
      {super.key,
      this.account,
      this.reference,
      this.amount,
      this.waitForConfirmation,
      this.onApprovalUrlHandler,
      this.metadata});

  final String? account, reference;
  final double? amount;
  final bool? waitForConfirmation;
  final Function(String?)? onApprovalUrlHandler;
  final Map<String, dynamic>? metadata;

  @override
  State<WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends SafeState<WithdrawSheet>
    with WidgetsBindingObserver {
  Map<String, dynamic>? merchantData, additionalData;
  List? methods;
  bool paymentMade = false;
  bool? showMerchantDetails, otpOk;
  int? selectedMethod;
  String currency = "UGX";
  double? amount;
  String? reference, account, working;
  ApiResponseMessage? apiResponseMessage;
  SocketIOService? socketIOService;

  listenForCallback() async {
    if (widget.waitForConfirmation == true) {
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        working = "Verifying transaction, please wait...";
      });
      socketIOService = await SocketIOService().init();
      socketIOService!.socket.on('callback', (data) {
        setState(() {
          working = null;
        });
        if (data['transactionId'] == reference) {
          if (data['status'] == 'success') {
            setState(() {
              apiResponseMessage = ApiResponseMessage(
                  success: true, message: "Transaction successful");
            });
            Future.delayed(const Duration(seconds: 3), () {
              closeDiag(status: TransactionStatus.success);
            });
          } else {
            setState(() {
              apiResponseMessage = ApiResponseMessage(
                  success: false, message: "Transaction was not successful");
            });
            Future.delayed(const Duration(seconds: 3), () {
              closeDiag(status: TransactionStatus.failed);
            });
          }
        }
      });

      Gmpay.instance.verifyTransactionTimer =
          Timer.periodic(const Duration(minutes: 1), (timer) async {
        var resp = await Gmpay.instance.verifyTransaction(reference!);

        if (resp != TransactionStatus.pending) {
          setState(() {
            working = null;
            apiResponseMessage = resp == TransactionStatus.success
                ? ApiResponseMessage(
                    success: true, message: "Transaction successful")
                : ApiResponseMessage(
                    success: false, message: "Transaction was not successful");
          });
          timer.cancel();

          Future.delayed(const Duration(seconds: 3), () {
            closeDiag(status: resp);
          });
        }
      });
    }
  }

  doPay() async {
    //validate form
    if (formDropDown.currentState!.saveAndValidate()) {
      setState(() {
        paymentMade = true;
        working = "Processing transaction, please wait...";
      });
      Map<String, dynamic> finalData = {'method': 'wapp'};

      finalData['amount'] = finalData['amount'] ?? widget.amount ?? 0;
      amount = finalData['amount'];

      finalData['account'] = formDropDown.currentState!.value['account'];

      if (widget.reference != null) {
        finalData['reference'] = widget.reference;
      } else {
        reference = finalData['reference'] ??
            Helpers.makeReference(merchantData?['businessName'],
                method: 'Withdraw');
        finalData['reference'] = reference;
      }

      if (widget.metadata != null) {
        finalData['metadata'] = widget.metadata;
      }

      var req = await Gmpay.instance.processTransaction(finalData);
      setState(() {
        working = null;
      });

      if (req?.isRight == true) {
        setState(() {
          apiResponseMessage = req!.right;
        });

        if (apiResponseMessage?.success == true) {
          listenForCallback();
        }
      } else {
        setState(() {
          apiResponseMessage = ApiResponseMessage(
              success: false,
              message:
                  "An error occurred, we could not complete your transaction, please try again later");
        });
      }
    }
  }

  @override
  void initState() {
    working = "Loading merchant details, please wait...";
    Gmpay.instance.loadBusiness().then((value) {
      if (mounted) {
        setState(() {
          working = null;
        });

        if (value == null) {
          setState(() {
            apiResponseMessage = ApiResponseMessage(
                message:
                    "Sorry we could not connect to our server, kindly check if you have an active internet access and try again",
                success: false);
          });
          return;
        }

        if (value.isRight == true) {
          setState(() {
            apiResponseMessage = value.right;
          });
          return;
        }

        setState(() {
          if (value.left!['data']['merchant'] != null) {
            merchantData = value.left!['data']['merchant'];
          }
          if (value.left!['data']['methods'] != null) {
            methods = value.left!['data']['methods'];
            for (var m in methods!) {
              if (m['form'] != null) {
                for (var f in m['form']['fields']) {
                  if (f['key'] == 'account') {
                    f['value'] = widget.account ?? "";
                  }
                }
              }
            }
          }
        });
      }
    });

    if (widget.reference != null) {
      reference = widget.reference;
    } else if (merchantData != null) {
      reference = Helpers.makeReference(merchantData?['businessName']);
    } else if (Gmpay.instance.apiKey != null &&
        Gmpay.instance.apiKey!.isNotEmpty) {
      reference = Helpers.makeReference(Gmpay.instance.apiKey!.split('-')[2]);
    } else {
      reference = Helpers.makeReference("GMPAY");
    }

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if ((paymentMade &&
                widget.waitForConfirmation == true &&
                working == null &&
                mounted &&
                apiResponseMessage == null) ||
            (apiResponseMessage?.success == true)) {
          listenForCallback();
        }
        break;

      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: GmpayWidgetTheme.light,
      child: working != null
          ? Busy(
              message: working,
            )
          : apiResponseMessage != null
              ? SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                            apiResponseMessage?.success == true
                                ? Icons.check_circle
                                : Icons.cancel_rounded,
                            color: apiResponseMessage?.success == true
                                ? Colors.green
                                : Colors.red,
                            size: 100),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            apiResponseMessage!.message ??
                                "Transaction successful",
                            textAlign: TextAlign.center,
                            style: GmpayTextStyles.body1,
                          ),
                        ),
                        if (widget.waitForConfirmation != true)
                          TextButton(
                              onPressed: () {
                                if (apiResponseMessage?.success == true) {
                                  closeDiag(status: TransactionStatus.pending);
                                } else {
                                  setState(() {
                                    apiResponseMessage = null;
                                  });
                                }
                              },
                              child: Text(
                                apiResponseMessage?.success == true
                                    ? "OK"
                                    : 'Try again',
                                style: GmpayTextStyles.body1,
                              ))
                      ],
                    ),
                  ),
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                  children: [
                    if (showMerchantDetails != true)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                                style: GmpayWidgetTheme.textButtonStyle,
                                onPressed: () {
                                  setState(() {
                                    showMerchantDetails = true;
                                  });
                                },
                                icon: const Icon(Icons.help_outline_rounded),
                                label: const Text("About your merchant"))),
                      ),
                    if (showMerchantDetails == true) ...[
                      MerchantInfoPage(
                        onBack: () {
                          setState(() {
                            showMerchantDetails = null;
                          });
                        },
                        merchantData: merchantData,
                      )
                    ] else ...[
                      const SimpleNotificationMessage(
                        message:
                            "Please note that you will receive the amount on your GMPay account only, if you dont have a GMPay account, kindly create one",
                        icon: Icons.warning_rounded,
                        type: SimpleNotificationMessageType.warning,
                      ),
                      const SizedBox(
                        height: gap_l,
                      ),
                      FormBuilder(
                        initialValue: {
                          'amount': widget.amount?.toString(),
                          'account': widget.account
                        },
                        key: formDropDown,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: gap_s),
                              child: FormBuilderTextField(
                                name: 'amount',
                                readOnly: (widget.amount != null &&
                                    widget.amount! > 0),
                                decoration: InputDecoration(
                                    prefix: Text("$currency  "),
                                    labelText: "Amount to pay"),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: gap_s),
                              child: FormBuilderTextField(
                                name: 'account',
                                decoration:
                                    const InputDecoration(labelText: "Account"),
                              ),
                            ),
                            InkWell(
                              onTap: doPay,
                              child: Container(
                                height: 40.0,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Center(
                                  child: Text("Process",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
    );
  }

  void closeDiag({TransactionStatus? status = TransactionStatus.failed}) {
    socketIOService?.onClose();
    Navigator.pop(
        context,
        TransactionInfo(
            reference: reference,
            amount: amount,
            account: account,
            status: status));
  }
}

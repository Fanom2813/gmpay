import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/debouncer.dart';
import 'package:gmpay/src/common/socket_listener.dart';
import 'package:gmpay/src/helpers.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/busy.dart';
import 'package:gmpay/src/widgets/merchant_info_page.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:json_to_form/json_schema.dart';
import 'package:map_enhancer/map_enhancer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gmpay/src/common/mounted_state.dart';

final formDropDown = GlobalKey<FormBuilderState>();

class PaymentSheet extends StatefulWidget {
  const PaymentSheet(
      {super.key,
      this.account,
      this.reference,
      this.amount,
      this.waitForConfirmation,
      this.onApprovalUrlHandler});

  final String? account, reference;
  final double? amount;
  final bool? waitForConfirmation;
  final Function(String?)? onApprovalUrlHandler;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends SafeState<PaymentSheet>
    with WidgetsBindingObserver {
  Map<String, dynamic>? merchantData, additionalData;
  final Debounce _debounce = Debounce(const Duration(seconds: 2));
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

  void requestOtp() async {
    additionalData ??= methods![selectedMethod!]['data'];

    setState(() {
      working = "Requesting OTP, please wait...";
    });
    var resp = await Gmpay.instance.requestOtp(
        methods![selectedMethod!]['data']['otpUrl'], {"account": account});

    if (resp.isRight) {
      apiResponseMessage = resp.right!;
    } else {
      otpOk = resp.left?['pinId'] != null;
      additionalData = {...additionalData!, ...resp.left!};
    }

    setState(() {
      working = null;
    });
  }

  doPay(data) async {
    //validate form
    if (formDropDown.currentState!.saveAndValidate()) {
      setState(() {
        paymentMade = true;
        working = "Processing transaction, please wait...";
      });
      Map<String, dynamic> finalData = {...methods![selectedMethod!]['data']};
      for (var f in ((data as Map)['fields'] as List)) {
        finalData[f['key']] = f['value'];
      }

      finalData['amount'] = finalData['amount'] ?? widget.amount ?? 0;
      amount = finalData['amount'];

      account = finalData['account'];

      if (widget.reference != null) {
        finalData['reference'] = widget.reference;
      } else {
        reference = finalData['reference'] ??
            Helpers.makeReference(merchantData?['businessName']);
        finalData['reference'] = reference;
      }

      additionalData ??= methods?[selectedMethod!]['data'];

      finalData = {...finalData, ...additionalData!};

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
      } else if (req?.isLeft == true) {
        if (req!.left!.hasIn(['approval_url'])) {
          setState(() {
            apiResponseMessage = ApiResponseMessage(
                success: true,
                message: "Please complete your transaction in the browser");
          });
          if (widget.onApprovalUrlHandler != null) {
            widget.onApprovalUrlHandler!(
                req.left!.getIn(['approval_url']) as String);
          } else {
            try {
              await launchUrl(
                  Uri.parse(req.left!.getIn(['approval_url']) as String));
            } catch (e) {
              setState(() {
                apiResponseMessage = ApiResponseMessage(
                    success: false,
                    message:
                        "An error occurred, we could not complete your transaction, please try again later");
              });
            }
          }
        }

        listenForCallback();
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
                      if (methods != null)
                        const Padding(
                          padding: EdgeInsets.only(top: gap_l, bottom: gap_m),
                          child: SectionTitle(
                            title: "Choose payment method",
                          ),
                        ),
                      FormBuilder(
                        initialValue: {
                          'selectedMethod': selectedMethod,
                          'amount': widget.amount?.toString(),
                        },
                        key: formDropDown,
                        child: Column(
                          children: [
                            FormBuilderField(
                              name: 'selectedMethod',
                              builder: (field) {
                                return Column(
                                  children: methods!.map((e) {
                                    var selected =
                                        methods!.indexOf(e) == selectedMethod;
                                    return Material(
                                      color: selected
                                          ? Colors.green.shade50
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(gap_s),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: gap_xs,
                                                horizontal: gap_s),
                                        selected: selected,
                                        onTap: () {
                                          setState(() {
                                            selectedMethod =
                                                methods!.indexOf(e);
                                          });
                                          field.didChange(methods!.indexOf(e));
                                        },
                                        title: Text(
                                          "${e['name']} ${selected ? '✔' : ''}",
                                          style: GmpayTextStyles.body1.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: e['description'] != null
                                            ? Text(
                                                e['description'] as String,
                                                textAlign: TextAlign.justify,
                                                style: GmpayTextStyles.subtitle2
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w300),
                                              )
                                            : null,
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                            )
                          ],
                        ),
                      ),
                      if (selectedMethod != null &&
                          methods![selectedMethod!]['data'] != null &&
                          methods![selectedMethod!]['data']['otpUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: gap_s),
                          child: ElevatedButton(
                              style: GmpayWidgetTheme.textButtonStyle,
                              onPressed: otpOk == true ? null : requestOtp,
                              child: Text(
                                  "Request OTP ${otpOk == true ? '✔' : ''}")),
                        ),
                      if (selectedMethod != null)
                        Container(
                          child: DefaultTextStyle.merge(
                            style: const TextStyle(color: Colors.black),
                            child: JsonSchema(
                              actionSave: (data) {
                                doPay(data);
                              },
                              buttonSave: Container(
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
                              formMap: methods![selectedMethod!]['form'],
                              onChanged: ((value) {
                                if (value['fields'] != null &&
                                    value['fields'].length > 0) {
                                  var cur = (value['fields'] as List).where(
                                      (element) =>
                                          element['key'] == 'currency');

                                  if (cur.isNotEmpty) {
                                    _debounce(() {
                                      setState(() {
                                        currency = cur.first['value'];
                                      });
                                    });
                                  }

                                  var account = (value['fields'] as List).where(
                                      (element) => element['key'] == 'account');
                                  setState(() {
                                    this.account = account.first['value'];
                                  });
                                }
                              }),
                              autovalidateMode: AutovalidateMode.always,
                            ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/debouncer.dart';
import 'package:gmpay/src/helpers.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/busy.dart';
import 'package:json_to_form/json_schema.dart';
import 'package:map_enhancer/map_enhancer.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _PaymentSheetState extends State<PaymentSheet>
    with WidgetsBindingObserver {
  Map<String, dynamic>? merchantData, additionalData;
  final Debounce _debounce = Debounce(const Duration(seconds: 2));
  List? methods;
  bool working = false, paymentMade = false;
  bool? showMerchantDetails;
  int? selectedMethod;
  String currency = "UGX";
  double? amount;
  String? reference, account;
  ApiResponseMessage? apiResponseMessage;

  listenForCallback() async {
    if (widget.waitForConfirmation == true) {
      await Future.delayed(const Duration(seconds: 3));
      var repetition = 0;
      setState(() {
        working = true;
      });
      Gmpay.instance.verifyTransactionTimer =
          Timer.periodic(const Duration(seconds: 7), (timer) async {
        var resp = await Gmpay.instance.verifyTransaction(reference!);

        if (resp != TransactionStatus.pending) {
          setState(() {
            working = false;
            apiResponseMessage = resp == TransactionStatus.success
                ? ApiResponseMessage(
                    success: true, message: "Transaction successful")
                : ApiResponseMessage(
                    success: false, message: "Transaction was not successful");
          });
          _debounce(() {
            timer.cancel();
            closeDiag(status: resp);
          });
        } else if (repetition == 5) {
          setState(() {
            working = false;
            apiResponseMessage = ApiResponseMessage(
                success: false,
                message:
                    "Transaction is still pending, we shall notify you when it is complete!");
          });
          _debounce(() {
            timer.cancel();
            closeDiag(status: TransactionStatus.pending);
          });
        }

        if (repetition <= 5) {
          repetition++;
        }
      });
    }
  }

  void requestOtp() async {
    if (additionalData == null) {
      setState(() {
        apiResponseMessage = ApiResponseMessage(
            success: false,
            message: "Ensure that you have provided all the required fields");
      });

      return;
    }

    setState(() {
      working = true;
    });
    var resp = await Gmpay.instance.requestOtp(
        methods![selectedMethod!]['data']['otpUrl'],
        {"account": additionalData!['account']});

    if (resp.isRight) {
      apiResponseMessage = resp.right!;
    } else {
      additionalData = {...additionalData!, ...resp.left!};
    }

    setState(() {
      working = false;
    });
  }

  doPay(data) async {
    //validate form
    if (formDropDown.currentState!.saveAndValidate()) {
      setState(() {
        paymentMade = true;
        working = true;
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
            Helpers.makeReference(merchantData!['businessName']);
        finalData['reference'] = reference;
      }

      var req = await Gmpay.instance.processTransaction(finalData);
      setState(() {
        working = false;
      });

      if (req?.isRight == true) {
        setState(() {
          apiResponseMessage = req!.right;
        });
      }

      if (req?.isLeft == true) {
        if (req!.left!.hasIn(['approval_url'])) {
          setState(() {
            apiResponseMessage = ApiResponseMessage(
                success: true,
                message: "Please complete your transaction in the browser");
          });
          if (widget.onApprovalUrlHandler != null) {
            widget.onApprovalUrlHandler!(
                req.left!.hasIn(['approval_url']) as String);
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
      }

      listenForCallback();
    }
  }

  @override
  void initState() {
    working = true;
    Gmpay.instance.loadBusiness().then((value) {
      if (mounted) {
        setState(() {
          working = false;
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
    } else {
      reference = Helpers.makeReference(merchantData!['businessName']);
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
        if (paymentMade) {
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
      child: working
          ? const Busy()
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
                            style: GmpayWidgetTheme.bodyMedium,
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
                                style: GmpayWidgetTheme.bodyMedium,
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
                                onPressed: () {
                                  setState(() {
                                    showMerchantDetails = true;
                                  });
                                },
                                icon: const Icon(Icons.help_outline_rounded),
                                label: const Text("About merchant"))),
                      ),
                    if (showMerchantDetails == true) ...[
                      if (merchantData != null) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  showMerchantDetails = null;
                                });
                              },
                              icon: const Icon(Icons.arrow_back_rounded)),
                        ),
                        if (merchantData!['businessName'] != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Business Name',
                            style: GmpayWidgetTheme.bodyLarge,
                          ),
                          SelectableText(
                            merchantData!['businessName'],
                            style: GmpayWidgetTheme.heading1,
                          )
                        ],
                        if (merchantData!['user']['email'] != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Contact',
                            style: GmpayWidgetTheme.bodyLarge,
                          ),
                          SelectableText(
                            merchantData!['user']['email'],
                            style: GmpayWidgetTheme.heading1,
                          )
                        ],
                      ]
                    ] else ...[
                      if (methods != null)
                        FormBuilder(
                          initialValue: {
                            'selectedMethod': selectedMethod,
                            'amount': widget.amount?.toString(),
                          },
                          key: formDropDown,
                          child: Column(
                            children: [
                              FormBuilderDropdown<int>(
                                decoration: const InputDecoration(
                                    isDense: true,
                                    labelText: "Select payment method"),
                                validator: FormBuilderValidators.required(),
                                items: methods!
                                    .map((e) => DropdownMenuItem(
                                        value: methods!.indexOf(e),
                                        child: Text(e['name'])))
                                    .toList(),
                                name: 'selectedMethod',
                                onChanged: (v) {
                                  setState(() {
                                    selectedMethod = v;
                                  });
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
                                    prefix: Text(currency),
                                  ),
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
                        TextButton(
                            onPressed: requestOtp,
                            child: const Text("Request OTP")),
                      if (selectedMethod != null)
                        Container(
                          key: UniqueKey(),
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
                                additionalData = value;

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
    Navigator.pop(
        context,
        TransactionInfo(
            reference: reference,
            amount: amount,
            account: account,
            status: status));
  }
}

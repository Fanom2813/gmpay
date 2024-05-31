import 'dart:async';
import 'dart:io';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/helpers.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/busy.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:gmpay/src/widgets/simple_notification_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gmpay/src/common/mounted_state.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet(
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
  State<PaymentSheet> createState() => _PaymentSheetState();
}

final methodFormKey = GlobalKey<FormBuilderState>();
final paymentFormKey = GlobalKey<FormBuilderState>();

class _PaymentSheetState extends SafeState<PaymentSheet>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? merchantData, additionalData;
  List<
      (
        String?,
        String?,
        String?,
        List<Map<dynamic, dynamic>>,
        String?,
        String?
      )>? methods;
  bool paymentMade = false;
  bool? showMerchantDetails, otpOk;
  int? selectedMethod;
  String currency = "UGX";
  double? amount;
  String? reference, account, working;
  ApiResponseMessage? apiResponseMessage;
  TabController? tabController;

  listenForCallback() async {
    setState(() {
      working = "Verifying transaction, please wait...";
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

  handleError(dynamic e) {
    if (e is SocketException) {
      setState(() {
        working = null;
        apiResponseMessage = ApiResponseMessage(
            message:
                "Sorry we could not connect to our server, kindly check if you have an active internet access and try again",
            success: false);
      });
    } else if (e is ApiResponseMessage) {
      setState(() {
        working = null;
        apiResponseMessage = e;
      });
    }
  }

  void requestOtp() async {
    // additionalData ??= methods![selectedMethod!]['data'];

    if (paymentFormKey.currentState?.saveAndValidate() == true) {
      setState(() {
        working = "Requesting OTP, please wait...";
        account = paymentFormKey.currentState!.value['account'];
      });

      var resp = await Gmpay.instance.requestOtp(
          methods![selectedMethod!].$6.toString(),
          methods![selectedMethod!].$5.toString(), {
        "metadata": {
          "account": paymentFormKey.currentState!.value['account'],
          "amount": widget.amount
        }
      });

      if (resp.$2 != null && resp.$2?.success == false) {
        apiResponseMessage = resp.$2;
      }

      if (resp.$1 != null) {
        setState(() {
          if (additionalData != null) {
            additionalData = {
              ...additionalData!,
              ...pick(resp.$1, 'data').asMapOrEmpty()
            };
          } else {
            additionalData = pick(resp.$1, 'data').asMapOrEmpty();
          }
          otpOk = true;
        });
      }

      setState(() {
        working = null;
      });
    }
  }

  doPay() async {
    //validate form
    if (paymentFormKey.currentState?.saveAndValidate() == true) {
      setState(() {
        working = "Processing transaction, please wait...";
      });
      Map<String, dynamic> finalData = {
        "metadata": {
          "account": paymentFormKey.currentState!.value['account'],
          "amount": widget.amount ?? 0,
          "reference": reference,
          ...widget.metadata != null ? widget.metadata! : {},
          ...additionalData != null ? additionalData! : {}
        }
      };

      var req = await Gmpay.instance.processTransaction(
          methods![selectedMethod!].$6.toString(),
          methods![selectedMethod!].$1.toString(),
          finalData);

      setState(() {
        working = null;
      });

      if (req.$2 != null) {
        setState(() {
          apiResponseMessage = req.$2;
        });

        // if (apiResponseMessage?.success == true) {
        //   listenForCallback();
        // }
      }

      if (req.$1 != null) {
        tabController?.animateTo(2);

        //if redirect_url in data
        var redirectUrl = pick(req.$1, 'data', 'redirect_url');
        if (!redirectUrl.isAbsent) {
          if (widget.onApprovalUrlHandler != null) {
            widget.onApprovalUrlHandler!(redirectUrl.asStringOrNull()!);
          } else {
            try {
              await launchUrl(Uri.parse(redirectUrl.asStringOrNull()!));
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
    }
  }

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 3);

    if (mounted) {
      setState(() {
        account = widget.account;
        amount = widget.amount;
      });
    }

    working = "Loading payment methods...";
    Gmpay.instance.loadPaymentMethods().then((value) {
      if (mounted) {
        setState(() {
          working = null;

          if (value.$1 != null) {
            methods = pick(value.$1)
                .asListOrEmpty((p0) => p0.asMapOrEmpty())
                .map((e) => (
                      pick(e, 'methodName').asStringOrNull(),
                      pick(e, 'optionName').asStringOrNull(),
                      pick(e, 'description').asStringOrNull(),
                      pick(e, 'extraFields').asListOrEmpty(
                        (p0) => p0.asMapOrEmpty(),
                      ),
                      pick(e, 'otpMethod').asStringOrNull(),
                      pick(e, 'module').asStringOrNull(),
                    ))
                .toList();
          }
        });
      }
    }).catchError(handleError);

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

    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
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
                children: [
                  if (apiResponseMessage != null) ...[
                    SimpleNotificationMessage(
                        type: apiResponseMessage!.success == true
                            ? SimpleNotificationMessageType.success
                            : SimpleNotificationMessageType.error,
                        message: apiResponseMessage!.message,
                        onClose: () {
                          if (mounted) {
                            setState(() {
                              apiResponseMessage = null;
                            });
                          }
                        }),
                    const SizedBox(
                      height: gap_s,
                    )
                  ],
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        methods == null
                            ? const Center(
                                child: SimpleNotificationMessage(
                                  icon: Icons.error,
                                  type: SimpleNotificationMessageType.error,
                                  message:
                                      "Sorry no payment methods available at the moment",
                                ),
                              )
                            : ListView(
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        top: gap_xs, bottom: gap_m),
                                    child: SectionTitle(
                                        title: "Unified Payments",
                                        subtitle:
                                            "Select Your Preferred Payment Method to continue"),
                                  ),
                                  FormBuilder(
                                    key: methodFormKey,
                                    initialValue: {
                                      'selectedMethod': selectedMethod,
                                    },
                                    child: Column(
                                      children: [
                                        FormBuilderField(
                                          name: 'selectedMethod',
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required()
                                          ]),
                                          builder: (field) {
                                            return Column(
                                              children: methods!.map((e) {
                                                var selected =
                                                    methods!.indexOf(e) ==
                                                        selectedMethod;
                                                return Material(
                                                  color: selected
                                                      ? Colors.green.shade50
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          gap_s),
                                                  child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: gap_xs,
                                                            horizontal: gap_s),
                                                    selected: selected,
                                                    onTap: () {
                                                      field.didChange(
                                                          methods!.indexOf(e));
                                                      setState(() {
                                                        selectedMethod =
                                                            methods!.indexOf(e);
                                                      });
                                                      tabController
                                                          ?.animateTo(1);
                                                    },
                                                    title: Text(
                                                      "${e.$2}",
                                                      style: GmpayTextStyles
                                                          .body1
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    subtitle: e.$3 != null
                                                        ? Text(
                                                            e.$3!,
                                                            textAlign: TextAlign
                                                                .justify,
                                                            style: GmpayTextStyles
                                                                .subtitle2
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300),
                                                          )
                                                        : null,
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            if (selectedMethod != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: gap_xs, bottom: gap_m),
                                child: SectionTitle(
                                    canGoBack: true,
                                    onBack: () {
                                      tabController?.animateTo(0);
                                    },
                                    title:
                                        "Paying with ${methods![selectedMethod!].$2}",
                                    subtitle:
                                        "${methods![selectedMethod!].$3}"),
                              ),
                            if (selectedMethod != null)
                              FormBuilder(
                                key: paymentFormKey,
                                initialValue: {
                                  'amount': amount?.toString(),
                                  'account': account,
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: gap_s, horizontal: gap_s),
                                      child: FormBuilderTextField(
                                        name: 'amount',
                                        readOnly: (widget.amount != null &&
                                            widget.amount! > 0),
                                        decoration: InputDecoration(
                                            prefix: Text("$currency  "),
                                            labelText: "Payable Amount"),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: gap_xxs, horizontal: gap_s),
                                      child: FormBuilderTextField(
                                        name: 'account',
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(),
                                        ]),
                                        decoration: const InputDecoration(
                                            labelText: "Account"),
                                      ),
                                    ),
                                    if (methods![selectedMethod!].$5 !=
                                        null) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: gap_s, horizontal: gap_s),
                                        child: FormBuilderTextField(
                                          name: 'otp',
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.minLength(4,
                                                allowEmpty: true)
                                          ]),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                              labelText: "OTP",
                                              suffixIcon: TextButton(
                                                  onPressed: requestOtp,
                                                  child: Text(
                                                      "Request OTP ${otpOk == true ? '✔' : ''}"))),
                                        ),
                                      ),
                                    ],
                                    ...methods![selectedMethod!].$4.map((e) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: gap_xxs,
                                            horizontal: gap_s),
                                        child: FormBuilderTextField(
                                          name: pick(e, 'key')
                                              .required()
                                              .asString(),
                                          validator:
                                              FormBuilderValidators.compose([
                                            if (pick(e, 'required')
                                                .asBoolOrFalse())
                                              FormBuilderValidators.required()
                                          ]),
                                          inputFormatters: (pick(e, 'type')
                                                      .asStringOrNull() ==
                                                  "Number")
                                              ? [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ]
                                              : null,
                                          decoration: InputDecoration(
                                            labelText:
                                                "${pick(e, 'label').required().asString()} ${(pick(e, 'required').asBoolOrFalse()) ? "(Required)" : "(Optional)"}",
                                          ),
                                        ),
                                      );
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: gap_s, horizontal: gap_s),
                                      child: ElevatedButton(
                                          style: GmpayWidgetTheme
                                              .textButtonStyle
                                              .copyWith(
                                            minimumSize: WidgetStateProperty
                                                .resolveWith<Size>((states) =>
                                                    const Size.fromHeight(50)),
                                          ),
                                          onPressed: doPay,
                                          child: const Text("Pay Now")),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Center(
                          child: ListView(
                            children: [
                              Icon(
                                  apiResponseMessage != null &&
                                          apiResponseMessage?.success == true
                                      ? Icons.check_circle_rounded
                                      : Icons.error_rounded,
                                  size: 150,
                                  color: apiResponseMessage != null &&
                                          apiResponseMessage?.success == true
                                      ? Colors.green.shade900
                                      : Colors.red.shade900),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: gap_xs, bottom: gap_m),
                                  child: SectionTitle(
                                      textCrossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      title: apiResponseMessage != null &&
                                              apiResponseMessage?.success ==
                                                  true
                                          ? "Transaction In Progress"
                                          : "Transaction Failed",
                                      subtitle: apiResponseMessage != null &&
                                              apiResponseMessage?.success ==
                                                  true
                                          ? "Your transaction is being processed"
                                          : "Try again later or contact your merchant for more information")),
                              const SizedBox(
                                height: gap_l,
                              ),
                              ElevatedButton(
                                  style:
                                      GmpayWidgetTheme.textButtonStyle.copyWith(
                                    minimumSize:
                                        WidgetStateProperty.resolveWith<Size>(
                                            (states) =>
                                                const Size.fromHeight(50)),
                                  ),
                                  onPressed: listenForCallback,
                                  child: const Text("Verify My Transaction")),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
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

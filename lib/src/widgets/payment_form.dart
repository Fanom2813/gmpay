import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/app_provider.dart';
import 'package:gmpay/src/common/constants.dart';
import 'package:gmpay/src/common/mounted_state.dart';
import 'package:gmpay/src/gmpay.dart';
import 'package:gmpay/src/helpers.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/theme.dart';
import 'package:gmpay/src/widgets/section_title.dart';
import 'package:gmpay/src/widgets/simple_notification_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'gmpay_header.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm(
      {super.key,
      this.account,
      this.reference,
      this.metadata,
      this.onApprovalUrlHandler,
      this.isWithdraw,
      this.amount});

  final String? account, reference;
  final double? amount;
  final String currency = "UGX";
  final Map<String, dynamic>? metadata;
  final Function(String?)? onApprovalUrlHandler;
  final bool? isWithdraw;

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends SafeState<PaymentForm> {
  final paymentFormKey = GlobalKey<FormBuilderState>();

  bool? otpOk;
  Map<String, dynamic>? additionalData;
  final PaymentMethod? paymentMethod = AppProvider.instance.method;

  String? working, account;

  @override
  void initState() {
    AppProvider.instance.prevPage = "payment_form";
    super.initState();
  }

  void requestOtp(BuildContext context) async {
    // additionalData ??= paymentMethod?['data'];

    if (paymentFormKey.currentState?.saveAndValidate() == true) {
      setState(() {
        working = "Requesting OTP, please wait...";
        account = paymentFormKey.currentState!.value['account'];
      });

      var resp = await Gmpay.instance.requestOtp(
          paymentMethod?.$6.toString(), paymentMethod?.$5.toString(), {
        "metadata": {
          "account": paymentFormKey.currentState!.value['account'],
          "amount": widget.amount
        }
      });

      if (resp.$2 != null && resp.$2?.success == false) {
        AppProvider.instance.apiResponseMessage = resp.$2;
        if (mounted) {
          WoltModalSheet.of(context).showPageWithId("failed_page");
        }
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

  doPay(BuildContext context) async {
    //validate form
    if (paymentFormKey.currentState?.saveAndValidate() == true) {
      setState(() {
        working = "Processing transaction, please wait...";
      });

      if (widget.metadata != null) {
        for (var inp in paymentFormKey.currentState!.value.keys) {
          // if (!widget.metadata!.containsKey(inp)) {
          widget.metadata![inp] = paymentFormKey.currentState!.value[inp];
          // }
        }
      }

      Map<String, dynamic> finalData = {
        "metadata": {
          "account": paymentFormKey.currentState!.value['account'],
          "amount": Helpers.toMoney(widget.amount),
          "reference": widget.reference,
          ...widget.metadata != null ? widget.metadata! : {},
          ...additionalData != null ? additionalData! : {}
        }
      };

      try {
        var req = await Gmpay.instance.processTransaction(
            paymentMethod?.$6.toString(),
            paymentMethod?.$1.toString(),
            finalData);

        setState(() {
          working = null;
        });

        if (req.$2 != null) {
          // setState(() {
          // apiResponseMessage = req.$2;
          // });

          AppProvider.instance.apiResponseMessage = req.$2;
          if (mounted) {
            if (AppProvider.instance.apiResponseMessage?.success == true) {
              WoltModalSheet.of(context).showPageWithId("success_page");
              AppProvider.instance.transactionInfo = TransactionInfo(
                  reference: widget.reference,
                  amount: widget.amount,
                  status: TransactionStatus.success);
            } else {
              WoltModalSheet.of(context).showPageWithId("failed_page");
              AppProvider.instance.transactionInfo = TransactionInfo(
                  reference: widget.reference,
                  amount: widget.amount,
                  status: TransactionStatus.failed);
            }
          }
        }

        if (req.$1 != null) {
          // tabController?.animateTo(2);

          //if redirect_url in data
          var redirectUrl = pick(req.$1, 'data', 'redirect_url');
          if (!redirectUrl.isAbsent) {
            if (widget.onApprovalUrlHandler != null) {
              widget.onApprovalUrlHandler!(redirectUrl.asStringOrNull()!);
            } else {
              try {
                await launchUrl(Uri.parse(redirectUrl.asStringOrNull()!));
              } catch (e) {
                // setState(() {
                AppProvider.instance.apiResponseMessage = ApiResponseMessage(
                    success: false,
                    message:
                        "An error occurred, we could not complete your transaction, please try again later");
                if (mounted) {
                  WoltModalSheet.of(context).showPageWithId("failed_page");
                }
                // });
              }
            }
          }
        }
      } catch (_) {
        AppProvider.instance.apiResponseMessage = ApiResponseMessage(
            success: false,
            message:
                "An error occurred, we could not complete your transaction, please try again later");
        if (mounted) {
          WoltModalSheet.of(context).showPageWithId("failed_page");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: GmpayWidgetTheme.light,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(gap_s),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: gap_xs, bottom: gap_m),
            child: SectionTitle(
              canGoBack: true,
              imageAsset: paymentMethod?.$7,
              onBack: () {
                WoltModalSheet.of(context).showPageWithId("payment_methods");
              },
              title:
                  "${widget.isWithdraw == true ? 'Withdrawing with' : 'Paying with'} ${paymentMethod?.$2}",
              subtitle: "${paymentMethod?.$3}",
              trailing: getMerchantInfoButton(context),
            ),
          ),
          if (paymentMethod?.$8 != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: gap_s, horizontal: gap_s),
              child: SimpleNotificationMessage(
                type: SimpleNotificationMessageType.info,
                icon: Icons.info_rounded,
                message: paymentMethod?.$8,
              ),
            ),
          FormBuilder(
            key: paymentFormKey,
            initialValue: {
              'amount': widget.amount?.toString(),
              'account': widget.account,
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: gap_s, horizontal: gap_s),
                  child: FormBuilderTextField(
                    name: 'amount',
                    readOnly: (widget.amount != null && widget.amount! > 0),
                    decoration: InputDecoration(
                        prefix: Text("${widget.currency}  "),
                        labelText: "Payable Amount"),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: gap_xxs, horizontal: gap_s),
                  child: FormBuilderTextField(
                    name: 'account',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: const InputDecoration(labelText: "Account"),
                  ),
                ),
                if (paymentMethod?.$5 != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: gap_s, horizontal: gap_s),
                    child: FormBuilderTextField(
                      name: 'otp',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.minLength(4,
                            checkNullOrEmpty: false)
                      ]),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          labelText: "OTP",
                          suffixIcon: TextButton(
                              onPressed: () {
                                requestOtp(context);
                              },
                              child: Text(
                                  "Request OTP ${otpOk == true ? '✔' : ''}"))),
                    ),
                  ),
                ],
                if (paymentMethod != null)
                  ...paymentMethod!.$4.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: gap_xxs, horizontal: gap_s),
                      child: FormBuilderTextField(
                        name: pick(e, 'key').required().asString(),
                        validator: FormBuilderValidators.compose([
                          if (pick(e, 'required').asBoolOrFalse())
                            FormBuilderValidators.required()
                        ]),
                        inputFormatters:
                            (pick(e, 'type').asStringOrNull() == "Number")
                                ? [FilteringTextInputFormatter.digitsOnly]
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
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: GmpayWidgetTheme.light.primaryColor,
                        foregroundColor:
                            GmpayWidgetTheme.light.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(gap_s)),
                      ),
                      onPressed: working == null
                          ? () {
                              doPay(context);
                            }
                          : null,
                      child: Text(working == null ? "Pay Now" : working!)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

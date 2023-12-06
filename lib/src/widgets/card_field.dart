import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gmpay/assets/images.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/mounted_state.dart';
import 'package:gmpay/src/theme/colors.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';

class GmpayCard extends StatefulWidget {
  const GmpayCard({super.key, this.amount, this.phoneNumber, this.reference});
  final double? amount;
  final String? phoneNumber, reference;

  @override
  State<GmpayCard> createState() => _GmpayCardState();
}

class _GmpayCardState extends SafeState<GmpayCard> {
  bool inProgress = true;
  String? paymentMethod = "app";
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic>? merchant;
  var errorMessage = "", successMessage = "";
  Timer? timer;

  processPayment() async {
    try {
      setState(() {
        inProgress = true;
        errorMessage = "";
      });
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
      } else {
        setState(() {
          inProgress = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        inProgress = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    amountController.text =
        widget.amount == null ? "0" : widget.amount.toString();
    phoneNumberController.text = widget.phoneNumber ?? "";
    if (widget.reference == null) {
      generateReference();
    }

    Gmpay.instance.getMerchantDetails().then((value) {
      if (value != null) {
        setState(() {
          merchant = value['data']['merchant'];
          inProgress = false;
        });
      }
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Gmpay.instance.isInitialized
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
            child: Card(
              elevation: 5,
              color: const Color(GmpayColors.primaryColor100),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color:
                        const Color(GmpayColors.primaryColor).withOpacity(.5),
                    width: 1.0),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.memory(
                          const Base64Decoder().convert(logo),
                          width: 150,
                        ),
                        if (inProgress)
                          const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: Color(GmpayColors.primaryColor),
                            ),
                          ),
                      ],
                    ),
                    if (merchant != null) ...[
                      const Divider(
                        height: 20,
                      ),
                      Text('${merchant?['businessName']}',
                          style: GmpayTextStyles.body1.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      const Divider(
                        height: 20,
                      )
                    ],
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(errorMessage,
                            style: GmpayTextStyles.body1.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    if (successMessage.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 70,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(successMessage,
                            textAlign: TextAlign.center,
                            style: GmpayTextStyles.body1
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const SizedBox(
                      height: 20,
                    ),
                    if (successMessage.isEmpty)
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: phoneNumberController,
                              enabled: !inProgress,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Phone number is required";
                                } else if (!value.startsWith("+")) {
                                  return "Phone number should start with country code";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  focusedBorder: GmpayWidgetTheme.borderInput,
                                  border: GmpayWidgetTheme.borderInput,
                                  hintText: "+256700000000",
                                  labelText: "Phone Number",
                                  helperText:
                                      "Your phone number start with +256"),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Amount is required";
                                } else if (double.tryParse(value) == null) {
                                  return "Amount should be a number";
                                } else if (double.parse(value) <= 0) {
                                  return "Amount should be greater than 0";
                                }
                                return null;
                              },
                              enabled: (widget.amount == null ||
                                      widget.amount! < 0) ||
                                  !inProgress,
                              decoration: const InputDecoration(
                                  focusedBorder: GmpayWidgetTheme.borderInput,
                                  border: GmpayWidgetTheme.borderInput,
                                  prefix: Text("UGX"),
                                  hintText: "1000",
                                  labelText: "Amount",
                                  helperText: "The amount to pay"),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (successMessage.isEmpty)
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              elevation: 1,
                              shape: const StadiumBorder(),
                              backgroundColor:
                                  const Color(GmpayColors.primaryColor)),
                          onPressed: inProgress
                              ? null
                              : () {
                                  processPayment();
                                },
                          child: const Text("Pay"))
                    else
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              elevation: 1,
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.blue),
                          onPressed: () {
                            setState(() {
                              inProgress = false;
                              successMessage = "";
                            });
                            generateReference();
                          },
                          child: const Text("Retry again"))
                  ],
                ),
              ),
            ),
          )
        : Text(
            "GMPAY NOT INITIALIZED",
            style: GmpayTextStyles.body1.copyWith(color: Colors.red),
          );
  }

  void generateReference() {
    setState(() {});
  }
}

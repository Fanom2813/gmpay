import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/helpers.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/theme/colors.dart';
import 'package:gmpay/src/theme/text_theme.dart';
import 'package:gmpay/src/theme/theme.dart';

class GmpayCard extends StatefulWidget {
  GmpayCard({super.key, this.amount, this.phoneNumber, this.reference});
  double? amount;
  String? phoneNumber, reference;

  @override
  State<GmpayCard> createState() => _GmpayCardState();
}

class _GmpayCardState extends State<GmpayCard> {
  bool inProgress = true;
  String? paymentMethod = "app", _reference;
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
        var amt = Helpers.toMoney(amountController.text);
        // var res = await Gmpay.instance.useRestApi(
        //     amt, paymentMethod, phoneNumberController.text,
        //     reference: _reference);
        // if (res.runtimeType == APIClientError) {
        //   setState(() {
        //     inProgress = false;
        //     errorMessage = res.error!;
        //   });
        //   return;
        // } else {
        //   setState(() {
        //     successMessage = res.toString();
        //   });
        //   //set timer and check for tansaction in interval
        //   timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        //     // var res = await Gmpay.instance.checkTransaction(_reference!);
        //     // if (res.runtimeType == APIClientSuccess) {
        //     //   setState(() {
        //     //     inProgress = false;
        //     //   });
        //     //   timer.cancel();
        //     //   return;
        //     // }
        //   });
        // }
        // print(res);
      } else {
        setState(() {
          inProgress = false;
        });
      }
    } catch (e) {
      print(e);
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
    //if reference null generate a new one using datetime and a unique id remove #,[,] from the UniqueKey string

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
      print(e);
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
                        Image.asset(
                          "assets/Gmpay_logo.png",
                          package: 'gmpay',
                          width: 150,
                        ),
                        if (inProgress)
                          const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
                            // if (_reference != null)
                            //   Padding(
                            //     padding: const EdgeInsets.only(bottom: 15.0),
                            //     child: RichText(
                            //       textAlign: TextAlign.start,
                            //       text: TextSpan(
                            //           text: "Reference: ",
                            //           style: GmpayTextStyles.body1
                            //               .copyWith(color: Colors.black),
                            //           children: [
                            //             TextSpan(
                            //                 text: _reference,
                            //                 style: GmpayTextStyles.body1.copyWith(
                            //                     color: Colors.black,
                            //                     fontWeight: FontWeight.bold))
                            //           ]),
                            //     ),
                            //   ),
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
                            // DropdownButtonFormField<String>(
                            //   decoration: const InputDecoration(
                            //       focusedBorder: GmpayWidgetTheme.borderInput,
                            //       border: GmpayWidgetTheme.borderInput,
                            //       labelText: "Payment Method",
                            //       helperText: "The payment method to use"),
                            //   value: paymentMethod,
                            //   onChanged: inProgress
                            //       ? null
                            //       : (value) {
                            //           setState(() {
                            //             paymentMethod = value;
                            //           });
                            //         },
                            //   items: Gmpay.instance.methods!.entries
                            //       .map((e) => DropdownMenuItem<String>(
                            //             value: e.key,
                            //             child: Text(e.value),
                            //           ))
                            //       .toList(),
                            // ),
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
    setState(() {
      _reference =
          "${DateTime.now().millisecondsSinceEpoch.toString()}-${UniqueKey().toString().replaceAll("#", "").replaceAll("[", "").replaceAll("]", "")}";
    });
  }
}

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gmpay/gmpay.dart';
import 'package:gmpay/gmpay_transaction_method.dart';
import 'package:gmpay/gmpay_transaction_types.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String _platformVersion = 'Unknown';
  final _gmpayPlugin = Gmpay();

  TextEditingController merchant = TextEditingController(text: "");
  TextEditingController amount = TextEditingController(text: "1000");
  TextEditingController phone = TextEditingController(text: "+256702016859");
  TextEditingController returnurl =
      TextEditingController(text: "https://www.google.com/");
  TextEditingController reference = TextEditingController(text: "ref-12-12-12");
  TextEditingController currency = TextEditingController(text: 'UGX');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GMPAY PLUGIN TEST'),
          centerTitle: true,
        ),
        body: ListView(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  child: Column(
                children: [
                  const Text("Fill The form correctly"),
                  TextFormField(
                    controller: merchant,
                    decoration: const InputDecoration(
                        hintText: "GMPAY-PUB...",
                        labelText: "Merchant Public Key",
                        helperText:
                            "You can get your public key in your dashboard in the GMPay App"),
                  ),
                  TextFormField(
                    controller: phone,
                    decoration: const InputDecoration(
                        hintText: "+256 ..",
                        labelText: "Customer Phone Number",
                        helperText:
                            "the phone number should contain the country code and start with a plus"),
                  ),
                  TextFormField(
                    controller: amount,
                    decoration: const InputDecoration(
                        hintText: "23",
                        labelText: "Amount",
                        helperText: "Amount should be a number"),
                  ),
                  TextFormField(
                    controller: returnurl,
                    decoration: const InputDecoration(
                        hintText: "https://..",
                        labelText: "Return URL (Optional)",
                        helperText:
                            "the return url after to be redirected to when transaction is done"),
                  ),
                  TextFormField(
                    controller: reference,
                    decoration: const InputDecoration(
                        hintText: "dnoie-23pk2-32",
                        labelText: "Reference (Optional)",
                        helperMaxLines: 2,
                        helperText:
                            "you can attach a custom reference to this transaction that will be submitted back by the our callback to your app"),
                  ),
                  TextFormField(
                    controller: currency,
                    decoration: const InputDecoration(
                        hintText: "UGX",
                        labelText: "Currency (Optional)",
                        helperText:
                            "The currency of the amount by default is UGX"),
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              print(_gmpayPlugin.useInAppBrowser(
                                merchant.text,
                                double.parse(amount.text),
                                phone.text,
                                GMPayTransactionType.topup,
                                reference: reference.text,
                                currency: currency.text,
                                returnUrl: returnurl.text,
                                callback: (p0) {
                                  print(p0);
                                },
                              ));
                            },
                            child: Text("Process With Webview")),
                      )),
                  SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              _gmpayPlugin
                                  .useRestApi(
                                    merchant.text,
                                    double.parse(amount.text),
                                    GMPayTransactionType.topup,
                                    GMPayTransactionMethod.mobilemoney,
                                    phone.text,
                                    reference: reference.text,
                                    currency: currency.text,
                                  )
                                  .then((value) =>
                                      print("Call done result ${value}"));
                            },
                            child: Text("Process Using Rest Api Call")),
                      ))
                ],
              )),
            ),
          ),
        ]),
      ),
    );
  }
}

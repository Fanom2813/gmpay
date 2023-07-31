// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:convert';

import 'package:gmpay/gmpay_transaction_method.dart';
import 'package:gmpay/gmpay_transaction_types.dart';
import 'package:http/http.dart' as http;

import 'in_app_web_browser.dart';

class Gmpay {
  Future<void> useInAppBrowser(
      String merchant, String phoneNumber, GMPayTransactionType type,
      {String? returnUrl,
      double? amount,
      String? currency,
      String? reference,
      Function(String?)? callback}) async {
    MyInAppBrowser inAppBrowser = MyInAppBrowser();
    final url = buildUrl(
        merchant: merchant,
        amount: amount,
        type: type,
        phoneNumber: phoneNumber,
        reference: reference,
        returnUrl: returnUrl,
        currency: currency);
    await inAppBrowser.browse(url, callback: callback, returnUrl: returnUrl);
  }

  Future<dynamic> useRestApi(
      String merchant,
      double amount,
      GMPayTransactionType type,
      GMPayTransactionMethod method,
      String phoneNumber,
      {String? currency,
      String? reference,
      String? cryptoHash}) async {
    var response = await http.post(
      Uri.parse('https://api.gmpayapp.com/api/v2/transactions/web-payment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'method': resolveMethodName(method),
        'amount': amount,
        'apiKey': merchant,
        if (method == GMPayTransactionMethod.crypto) ...{
          'hash': cryptoHash,
          'usdt': 'usdtTotal',
        },
        if (reference != null) ...{'reference': reference},
        'currency': currency ?? 'ugx'
      }),
    );

    return jsonDecode(response.body);
  }

  String resolveMethodName(GMPayTransactionMethod method) {
    switch (method) {
      case GMPayTransactionMethod.mobilemoney:
        return "mm";
      case GMPayTransactionMethod.intern:
        return "app";
      case GMPayTransactionMethod.crypto:
        return "cp";
      case GMPayTransactionMethod.paypal:
        return "pp";
    }
  }

  String buildUrl(
      {String? merchant,
      double? amount,
      String? phoneNumber,
      GMPayTransactionType? type = GMPayTransactionType.topup,
      String? returnUrl,
      String? currency,
      String? reference}) {
    currency = currency ?? 'UGX';
    returnUrl = returnUrl ?? 'https://greenmondaytv.com/thankyou.html';
    return "https://payments.gmpayapp.com/#/${type == GMPayTransactionType.topup ? 'checkout' : 'cashout'}?phone=${phoneNumber?.replaceAll("+", "")}${amount != null && amount > 0 ? "&amount=$amount" : ""}&return=$returnUrl&merchant=$merchant&reference=$reference&currency=$currency";
  }
}

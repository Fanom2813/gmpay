// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/model/transaction_info.dart';
import 'package:gmpay/src/widgets/payment_sheet.dart';
import 'package:gmpay/src/common/api_client.dart';
import 'package:gmpay/src/common/constants.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/widgets/bottom_sheet.dart';
import 'package:http/http.dart' as http;

class Gmpay {
  static Gmpay? _instance;
  Gmpay._();
  static Gmpay get instance => _instance ??= Gmpay._();

  final apiClient = ApiClient(AppConstants.baseUrl);

  Timer? verifyTransactionTimer;

  String? apiKey, secretKey;
  // Map<String, String>? methods = {
  //   "app": "GMpay App",
  //   "mm": "Mobile Money",
  //   "cp": "Crypto",
  //   "pp": "Paypal",
  // };

  ///initialize the plugin with your public key
  void initialize(String key, {String? secret}) {
    apiKey = key;
    secretKey = secret;
  }

  bool get isInitialized => apiKey != null;

  /// initialize the payment
  void pay(double? amount, {String? key, String? reference, String? currency}) {
    if (apiKey == null && key == null) {
      throw Exception("You must initialize the plugin with your public key");
    } else if (key != null) {
      apiKey = key;
    }

    //show the payment sheet
    // PaymentSheet.show(amount, reference: reference, currency: currency);
  }

  Future<Either<Map<String, dynamic>?, ApiResponseMessage?>?>
      loadBusiness() async {
    try {
      return await apiClient.postRequest("merchant/info", {"apiKey": apiKey});
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getMerchantDetails() async {
    var response = await http.post(
      Uri.parse('https://api.gmpayapp.com/api/v2/merchant/info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'apiKey': apiKey,
      }),
    );
    return jsonDecode(response.body);
  }

  // Future<void> useInAppBrowser(
  //     String merchant, String phoneNumber, GMPayTransactionType type,
  //     {String? returnUrl,
  //     double? amount,
  //     String? currency,
  //     String? reference,
  //     Function(String?)? callback}) async {
  //   MyInAppBrowser inAppBrowser = MyInAppBrowser();
  //   final url = buildUrl(
  //       merchant: merchant,
  //       amount: amount,
  //       type: type,
  //       phoneNumber: phoneNumber,
  //       reference: reference,
  //       returnUrl: returnUrl,
  //       currency: currency);
  //   await inAppBrowser.browse(url, callback: callback, returnUrl: returnUrl);
  // }

  void presentPaymentSheet(context,
      {double? amount,
      String? account,
      String? reference,
      bool? waitForConfirmation,
      Function(TransactionInfo?)? callback,
      Function(String?)? approvalUrlHandler}) {
    final ScrollController scrollController = ScrollController();
    final NavBottomSheetController navBottomSheetController =
        NavBottomSheetController();
    showNavBottomSheet(
      context: context,
      navBottomSheetController: navBottomSheetController,
      isDismissible: true,
      backdropColor: Colors.white.withOpacity(0.1),
      bottomSheetHeight: 600.0,
      bottomSheetBodyHasScrollView: true,
      bottomSheetBodyScrollController: scrollController,
      bottomSheetHeader: Stack(
        children: [
          Column(
            children: [
              Image.asset(
                "assets/Gmpay_logo.png",
                package: 'gmpay',
                width: 150,
              ),
              const Divider(),
              const Text(
                "Be Modern, Be Green",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Positioned(
              right: 10,
              top: 10,
              child: TextButton(
                  onPressed: () {
                    navBottomSheetController.close();
                    callback!(null);
                  },
                  child: const Text("Cancel"))),
        ],
      ),
      bottomSheetBody: PaymentSheet(
        amount: amount,
        account: account,
        waitForConfirmation: waitForConfirmation,
      ),
    ).then((onValue) {
      if (callback != null) {
        callback(onValue);
      }
    });
  }

  // Future<dynamic> useRestApi(
  //     double? amount, String? method, String? phoneNumber,
  //     {String? currency, String? reference, String? cryptoHash}) async {
  //   var headers = <String, String>{
  //     'Content-Type': 'application/json; charset=UTF-8',
  //   };
  //   if (secretKey != null) {
  //     headers['secret'] = secretKey!;
  //   }
  //   var response = await http.post(
  //     Uri.parse('${AppConstants.baseUrl}transactions/web-payment'),
  //     headers: headers,
  //     body: jsonEncode({
  //       'method': method,
  //       'amount': amount,
  //       'apiKey': apiKey,
  //       'account': phoneNumber,
  //       if (method == "cp") ...{
  //         'hash': cryptoHash,
  //         'usdt': 'usdtTotal',
  //       },
  //       if (reference != null) ...{'reference': reference},
  //       'currency': currency ?? 'ugx'
  //     }),
  //   );

  //   var resp = jsonDecode(response.body);
  //   //if resp status code not success then return success false
  //   if (resp['status'] != 200) {
  //     return APIClientError.fromJson(resp);
  //   } else {
  //     return APIClientSuccess.fromJson(resp);
  //   }
  // }

  // Future<dynamic> checkTransaction(String reference) async {
  //   var response = await http.get(
  //     Uri.parse(
  //         'https://api.gmpayapp.com/api/v2/transactions/check/${reference}'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'apiKey': apiKey!,
  //       'secret': secretKey ?? ""
  //     },
  //   );

  //   var resp = jsonDecode(response.body);
  //   print(resp);
  //   //if resp status code not success then return success false
  //   if (resp['status'] != 200) {
  //     return APIClientError.fromJson(resp);
  //   } else if (resp['data']['status'] == "success") {
  //     return APIClientSuccess.fromJson(resp);
  //   }

  //   return APIClientError.fromJson(resp);
  // }

  // String resolveMethodName(GMPayTransactionMethod method) {
  //   switch (method) {
  //     case GMPayTransactionMethod.mobilemoney:
  //       return "mm";
  //     case GMPayTransactionMethod.intern:
  //       return "app";
  //     case GMPayTransactionMethod.crypto:
  //       return "cp";
  //     case GMPayTransactionMethod.paypal:
  //       return "pp";
  //   }
  // }

  // String buildUrl(
  //     {String? merchant,
  //     double? amount,
  //     String? phoneNumber,
  //     GMPayTransactionType? type = GMPayTransactionType.topup,
  //     String? returnUrl,
  //     String? currency,
  //     String? reference}) {
  //   currency = currency ?? 'UGX';
  //   returnUrl = returnUrl ?? 'https://greenmondaytv.com/thankyou.html';
  //   return "https://api.gmpayapp.com/api/v2/transactions/init?phone=${phoneNumber?.replaceAll("+", "")}${amount != null && amount > 0 ? "&amount=$amount" : ""}&return=$returnUrl&merchant=$merchant&reference=$reference&currency=$currency";
  // }

  Future<Either<Map<String, dynamic>?, ApiResponseMessage?>> requestOtp(
      String otpUrl, Map<String, dynamic> args) async {
    return await apiClient.postRequest(otpUrl, args);
  }

  Future<Either<Map<String, dynamic>?, ApiResponseMessage?>?>
      processTransaction(Map<String, dynamic> finalData) async {
    try {
      return await apiClient.postRequest("transactions/web-payment", finalData);
    } catch (e) {
      return null;
    }
  }

  Future<TransactionStatus?> verifyTransaction(String? s) async {
//     {
//     "status": 200,
//     "statusText": "OK",
//     "data": {
//         "status": "pending",
//         "updatedAt": "2023-10-16T13:26:10.000Z",
//         "createdAt": "2023-10-16T13:26:10.000Z",
//         "amount": "1000.00",
//         "reference": "1697462694937-e0166"
//     }
// }
    try {
      var r = await apiClient.getRequest("transactions/check/$s");
      if (r.isLeft) {
        var data = r.left;
        if (data != null) {
          return TransactionStatus.values
              .firstWhere((element) => element.name == data['data']['status']);
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

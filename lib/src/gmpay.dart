import 'dart:async';
import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/widgets/gmpay_header.dart';
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

  String? apiKey, secretKey, package;

  bool? busy;

  ///initialize the plugin with your public key
  void initialize({String? key, String? secret, String? packageName}) {
    apiKey = key;
    secretKey = secret;
    package = packageName;
  }

  bool get isInitialized => apiKey != null || package != null;

  /// initialize the payment
  void pay(double? amount, {String? key, String? reference, String? currency}) {
    if (apiKey == null && key == null && package == null) {
      throw Exception("You must initialize the plugin with your public key");
    } else if (key != null) {
      apiKey = key;
    }

    //show the payment sheet
  }

  Future<(dynamic, ApiResponseMessage?)> loadBusiness() async {
    return await apiClient.postRequest("merchant/info", {"apiKey": apiKey});
  }

  Future<(dynamic, ApiResponseMessage?)> loadPaymentMethods() async {
    return await apiClient.getRequest(
        "${AppConstants.base}/modules/can-process-payment",
        noUseBaseUrl: true);
  }

  Future<(dynamic, ApiResponseMessage?)> loadInfo() async {
    return await apiClient.getRequest("${AppConstants.base}/merchant",
        noUseBaseUrl: true);
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

  void presentPaymentSheet(context,
      {double? amount,
      String? account,
      String? reference,
      bool? waitForConfirmation,
      Function(TransactionInfo?)? callback,
      Function(String?)? approvalUrlHandler,
      Map<String, dynamic>? metadata}) {
    if (busy == true) {
      return;
    }
    busy = true;

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
      bottomSheetHeader: GmpayHeader(
        navBottomSheetController: navBottomSheetController,
        // onCanceled: () {
        //   busy = null;
        //   if (callback != null) {
        //     callback(null);
        //   }
        // }
      ),
      bottomSheetBody: PaymentSheet(
        amount: amount,
        account: account,
        waitForConfirmation: waitForConfirmation,
        reference: reference,
        onApprovalUrlHandler: approvalUrlHandler,
        metadata: metadata,
      ),
    ).then((onValue) {
      busy = null;
      if (callback != null) {
        callback(onValue);
      }
    });
  }

  void presentWithdrawSheet(context,
      {double? amount,
      String? account,
      String? reference,
      bool? waitForConfirmation,
      Function(TransactionInfo?)? callback,
      Map<String, dynamic>? metadata}) {
    return;

    // if (busy == true) {
    //   return;
    // }
    // busy = true;

    // final ScrollController scrollController = ScrollController();
    // final NavBottomSheetController navBottomSheetController =
    //     NavBottomSheetController();
    // showNavBottomSheet(
    //   context: context,
    //   navBottomSheetController: navBottomSheetController,
    //   isDismissible: true,
    //   backdropColor: Colors.white.withOpacity(0.1),
    //   bottomSheetHeight: 600.0,
    //   bottomSheetBodyHasScrollView: true,
    //   bottomSheetBodyScrollController: scrollController,
    //   bottomSheetHeader: GmpayHeader(
    //       navBottomSheetController: navBottomSheetController,
    //       onCanceled: () {
    //         busy = null;
    //         if (callback != null) {
    //           callback(null);
    //         }
    //       }),
    //   bottomSheetBody: WithdrawSheet(
    //     amount: amount,
    //     account: account,
    //     waitForConfirmation: waitForConfirmation,
    //     reference: reference,
    //     metadata: metadata,
    //   ),
    // ).then((onValue) {
    //   busy = null;
    //   if (callback != null) {
    //     callback(onValue);
    //   }
    // });
  }

  Future<(dynamic, ApiResponseMessage?)> requestOtp(
      String? module, String? method, Map<String, dynamic> args) async {
    return await apiClient.postRequest('transactions/$module/$method', args);
  }

  Future<(dynamic, ApiResponseMessage?)> processTransaction(
      String? module, String? method, Map<String, dynamic> finalData) async {
    return await apiClient.postRequest(
        "transactions/$module/$method", finalData);
  }

  Future<TransactionStatus?> verifyTransaction(String? s) async {
    try {
      var r = await apiClient.getRequest("transactions/check/$s");
      if (r.$1 != null) {
        return TransactionStatus.values.firstWhere(
            (element) => element.name == pick(r.$1, 'status').asStringOrNull());
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  verifyTransactionAndWait(
      String reference, Function(TransactionStatus?) callback) async {
    var repetition = 0;
    Gmpay.instance.verifyTransactionTimer =
        Timer.periodic(const Duration(seconds: 7), (timer) async {
      var resp = await Gmpay.instance.verifyTransaction(reference);

      if (resp == TransactionStatus.success) {
        callback(resp);
        timer.cancel();
      } else if (repetition == 5) {
        callback(resp);
        timer.cancel();
      }

      if (repetition <= 5) {
        repetition++;
      }
    });
  }
}

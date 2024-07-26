import 'dart:async';
import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/app_provider.dart';
import 'package:gmpay/src/widgets/failed_page.dart';
import 'package:gmpay/src/widgets/gmpay_header.dart';
import 'package:gmpay/src/common/api_client.dart';
import 'package:gmpay/src/common/constants.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:gmpay/src/widgets/merchant_info_page.dart';
import 'package:gmpay/src/widgets/payment_form.dart';
import 'package:gmpay/src/widgets/select_payment_method.dart';
import 'package:gmpay/src/widgets/success_page.dart';
import 'package:gmpay/src/widgets/verification_sheet.dart';
import 'package:http/http.dart' as http;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Gmpay {
  static Gmpay? _instance;
  Gmpay._();
  static Gmpay get instance => _instance ??= Gmpay._();

  final apiClient = ApiClient(AppConstants.baseUrl);

  Timer? verifyTransactionTimer;

  String? apiKey, secretKey, package;
  bool? test;

  ///initialize the plugin with your public key
  void initialize(
      {String? key, String? secret, String? packageName, bool? testMode}) {
    apiKey = key;
    secretKey = secret;
    package = packageName;
    test = testMode;
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

  Future<(dynamic, ApiResponseMessage?)> loadWithdrawMethods() async {
    return await apiClient.getRequest(
        "${AppConstants.base}/modules/can-process-withdraw",
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

  /// Presents the payment sheet.
  ///
  /// This method is responsible for displaying the payment sheet in the given [context].
  /// It allows users to make payments and complete transactions.
  ///
  /// Parameters:
  /// - `context`: The build context in which the payment sheet will be displayed.
  void presentPaymentSheet(context,
      {double? amount,
      String? account,
      String? reference,
      bool? waitForConfirmation,
      Function(TransactionInfo?)? callback,
      Function(String?)? approvalUrlHandler,
      Map<String, dynamic>? metadata}) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        final List<WoltModalSheetPage> pages = <WoltModalSheetPage>[
          WoltModalSheetPage(
            id: "payment_methods",
            isTopBarLayerAlwaysVisible: true,
            topBar: const GmpayHeader(),
            enableDrag: true,
            child: const SelectPaymentMethod(),
            backgroundColor: Colors.white,
          ),
          WoltModalSheetPage(
              backgroundColor: Colors.white,
              isTopBarLayerAlwaysVisible: true,
              topBar: const GmpayHeader(),
              id: "payment_form",
              child: PaymentForm(
                account: account,
                amount: amount,
                metadata: metadata,
                onApprovalUrlHandler: approvalUrlHandler,
                reference: reference,
              )),
          WoltModalSheetPage(
              backgroundColor: Colors.green.shade900,
              id: "success_page",
              child: SuccessPage(
                onDone: () {
                  if (callback != null) {
                    callback(AppProvider.instance.transactionInfo);
                  }
                  Navigator.pop(context);
                },
              )),
          WoltModalSheetPage(
              backgroundColor: Colors.red.shade900,
              id: "failed_page",
              child: FailedPage(
                onDone: () {
                  if (callback != null) {
                    callback(AppProvider.instance.transactionInfo);
                  }
                  Navigator.pop(context);
                },
              )),
          WoltModalSheetPage(
              id: "merchant_info",
              isTopBarLayerAlwaysVisible: true,
              backgroundColor: Colors.white,
              topBar: const GmpayHeader(
                hideInfoButton: true,
              ),
              child: const MerchantInfoPage()),
        ];

        return pages.map((WoltModalSheetPage page) => page).toList();
      },
      onModalDismissedWithBarrierTap: () {
        if (callback != null) {
          callback(AppProvider.instance.transactionInfo);
        }
        Navigator.pop(context);
      },
      onModalDismissedWithDrag: () {
        if (callback != null) {
          callback(AppProvider.instance.transactionInfo);
        }
        Navigator.pop(context);
      },
    ).then((value) {
      debugPrint("Modal dismissed");
      AppProvider.resetInstance();
    });
  }

  /// Presents a verification sheet.
  ///
  /// This method is responsible for displaying a verification sheet to the user.
  /// The verification sheet is used to verify certain information or actions
  /// before proceeding with further operations.
  ///
  /// Example usage:
  /// ```dart
  /// presentVerificationSheet();
  /// ```
  void presentVerificationSheet(
    context, {
    String? reference,
    Function(TransactionInfo?)? callback,
  }) {
    if (reference == null) {
      return;
    }

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        final List<WoltModalSheetPage> pages = <WoltModalSheetPage>[
          WoltModalSheetPage(
            id: "verification_page",
            isTopBarLayerAlwaysVisible: true,
            topBar: const GmpayHeader(),
            enableDrag: true,
            child: VerificationPage(
              reference: reference,
            ),
            backgroundColor: Colors.white,
          ),
          WoltModalSheetPage(
              backgroundColor: Colors.green.shade900,
              id: "success_page",
              child: SuccessPage(
                onDone: () {
                  if (callback != null) {
                    callback(AppProvider.instance.transactionInfo);
                  }
                  Navigator.pop(context);
                },
              )),
          WoltModalSheetPage(
              backgroundColor: Colors.red.shade900,
              id: "failed_page",
              child: FailedPage(
                onDone: () {
                  if (callback != null) {
                    callback(AppProvider.instance.transactionInfo);
                  }
                  Navigator.pop(context);
                },
              )),
          WoltModalSheetPage(
              id: "merchant_info",
              isTopBarLayerAlwaysVisible: true,
              backgroundColor: Colors.white,
              topBar: const GmpayHeader(
                hideInfoButton: true,
              ),
              child: const MerchantInfoPage()),
        ];

        return pages.map((WoltModalSheetPage page) => page).toList();
      },
      onModalDismissedWithBarrierTap: () {
        if (callback != null) {
          callback(AppProvider.instance.transactionInfo);
        }
        Navigator.pop(context);
      },
      onModalDismissedWithDrag: () {
        if (callback != null) {
          callback(AppProvider.instance.transactionInfo);
        }
        Navigator.pop(context);
      },
    ).then((value) {
      debugPrint("Modal dismissed");
      Gmpay.instance.verifyTransactionTimer?.cancel();
      AppProvider.resetInstance();
    });

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
    //       // navBottomSheetController: navBottomSheetController,
    //       ),
    //   bottomSheetBody: VerificationSheet(
    //     reference: reference,
    //   ),
    // ).then((onValue) {
    //   if (callback != null) {
    //     callback(onValue);
    //   }
    // });
  }

  /// Presents a withdrawal sheet.
  ///
  /// This method is used to display a withdrawal sheet in the given [context].
  /// The sheet allows the user to initiate a withdrawal process.
  void presentWithdrawSheet(context,
      {double? amount,
      String? account,
      String? reference,
      bool? waitForConfirmation,
      Function(TransactionInfo?)? callback,
      Map<String, dynamic>? metadata}) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        final List<WoltModalSheetPage> pages = <WoltModalSheetPage>[
          WoltModalSheetPage(
            id: "payment_methods",
            isTopBarLayerAlwaysVisible: true,
            topBar: const GmpayHeader(),
            enableDrag: true,
            child: const SelectPaymentMethod(
              isWithdraw: true,
            ),
            backgroundColor: Colors.white,
          ),
          WoltModalSheetPage(
              backgroundColor: Colors.white,
              isTopBarLayerAlwaysVisible: true,
              topBar: const GmpayHeader(),
              id: "payment_form",
              child: PaymentForm(
                isWithdraw: true,
                account: account,
                amount: amount,
                metadata: metadata,
                reference: reference,
              )),
          WoltModalSheetPage(
              backgroundColor: Colors.green.shade900,
              id: "success_page",
              child: SuccessPage(
                onDone: () {
                  if (callback != null) {
                    callback(AppProvider.instance.transactionInfo);
                  }
                  Navigator.pop(context);
                },
              )),
          WoltModalSheetPage(
              backgroundColor: Colors.red.shade900,
              id: "failed_page",
              child: FailedPage(
                onDone: () {
                  if (callback != null) {
                    callback(AppProvider.instance.transactionInfo);
                  }
                  Navigator.pop(context);
                },
              )),
          WoltModalSheetPage(
              id: "merchant_info",
              isTopBarLayerAlwaysVisible: true,
              backgroundColor: Colors.white,
              topBar: const GmpayHeader(
                hideInfoButton: true,
              ),
              child: const MerchantInfoPage()),
        ];

        return pages.map((WoltModalSheetPage page) => page).toList();
      },
      onModalDismissedWithBarrierTap: () {
        if (callback != null) {
          callback(AppProvider.instance.transactionInfo);
        }
        Navigator.pop(context);
      },
      onModalDismissedWithDrag: () {
        if (callback != null) {
          callback(AppProvider.instance.transactionInfo);
        }
        Navigator.pop(context);
      },
    ).then((value) {
      debugPrint("Modal dismissed");
      AppProvider.resetInstance();
    });

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
    //       // navBottomSheetController: navBottomSheetController,
    //       ),
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
        "transactions/$module/$method", {...finalData, "test": test});
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

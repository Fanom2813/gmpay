import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/constants.dart';
import 'package:gmpay/src/model/api_response.dart';

class AppProvider {
  AppProvider._privateConstructor();

  static AppProvider? _instance = AppProvider._privateConstructor();

  static AppProvider get instance {
    _instance ??= AppProvider._privateConstructor();
    return _instance!;
  }

  static void resetInstance() {
    _instance = null;
  }

  TransactionInfo? transactionInfo;

  PaymentMethod? method;
  ApiResponseMessage? apiResponseMessage;
  String? prevPage;
}

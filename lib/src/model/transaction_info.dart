import 'package:gmpay/src/model/transaction_status.dart';

class TransactionInfo {
  String? reference, method, account, currency;
  TransactionStatus? status;
  double? amount;

  TransactionInfo(
      {this.reference,
      this.method,
      this.account,
      this.currency,
      this.amount,
      this.status});

  String resolveMethodName() {
    switch (method) {
      case 'app':
        return 'GMPay App';
      case 'card':
        return 'Payment Card';
      case 'bank':
        return 'Bank Transfer';
      case 'cp':
        return 'Crypto Payment';
      case 'pp':
        return 'PayPal';
      case 'mm':
      case 'mm2':
      case 'mm3':
        return 'Mobile Money';
      default:
        return 'New Method';
    }
  }

  //to json
  Map<String, dynamic> toJson() => {
        "reference": reference,
        "method": resolveMethodName(),
        "account": account,
        "currency": currency,
        "amount": amount,
        "status": status?.name,
      };
}

class AppConstants {
  static const base = "https://gateway.gmpayapp.com";
  // static const base = "http://localhost:1999";
  // static const base = "https://gmpay-api-local-test.serveo.net";
  static const baseUrl = "$base/api/v4";
}

typedef PaymentMethod = (
  String?,
  String?,
  String?,
  List<Map<dynamic, dynamic>>,
  String?,
  String?,
  String?,
  String?,
);

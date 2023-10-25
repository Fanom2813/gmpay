class Helpers {
  //format anything to double
  static double toMoney(value) {
    if (value.runtimeType == String) {
      return double.tryParse(value) ?? 0;
    } else if (value.runtimeType == double) {
      return value;
    } else if (value.runtimeType == int) {
      return (value as int).toDouble();
    }
    return 0;
  }

  //make random reference
  static String makeReference(String? companyName) {
    return "${companyName}-${DateTime.now().millisecondsSinceEpoch}";
  }
}

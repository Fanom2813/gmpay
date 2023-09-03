import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  var options = InAppBrowserClassOptions(
      crossPlatform: InAppBrowserOptions(hideUrlBar: true),
      inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));

  Function(String?)? theCallback;
  late String? _returnUrl;

  Future<void> browse(String? url,
      {Function(String?)? callback, String? returnUrl}) async {
    if (callback != null) {
      theCallback = callback;
    }
    _returnUrl = returnUrl;

    if (url != null) {
      await openUrlRequest(
          urlRequest: URLRequest(url: Uri.parse(url)), options: options);
    } else {
      if (callback != null) {
        callback("Transaction ended");
      }
    }
  }

  @override
  Future onBrowserCreated() async {
    // print("Browser Created!");
  }

  @override
  Future onLoadStart(url) async {
    // print("Started $url");
  }

  @override
  Future onLoadStop(url) async {
    // print(
    //     "Stopped $url $_returnUrl ${url.toString().contains(_returnUrl ?? "")}");
    // var t = url.toString().toLowerCase();
    // var d = '${_returnUrl?.toLowerCase()}'.contains(t);

    if (_returnUrl != null) {
      // var u = Uri.parse(_returnUrl!);
      // print(u.toString());
      if (url.toString().contains(_returnUrl!)) {
        if (theCallback != null) {
          theCallback!("Transaction Completed");
        }
        close();
      }
    }
  }

  @override
  void onLoadError(url, code, message) {
    // print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    // print("Progress: $progress");
  }

  @override
  void onExit() {
    // print("Browser closed!");
  }
}

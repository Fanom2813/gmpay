import 'dart:convert';
import 'package:deep_pick/deep_pick.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/errors.dart';
import 'package:gmpay/src/common/http_status_extension.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient(this.baseUrl);

  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (Gmpay.instance.secretKey != null) ...{
        'apiKey': '${Gmpay.instance.apiKey}',
      },
      if (Gmpay.instance.secretKey != null) ...{
        'secret': '${Gmpay.instance.secretKey}',
      },
      if (Gmpay.instance.package != null) ...{
        'authorization': '${Gmpay.instance.package}',
      }
    };
  }

  Future<(dynamic, ApiResponseMessage?)> getRequest(String endpoint,
      {bool? noUseBaseUrl}) async {
    final response = await http.get(
        Uri.parse(noUseBaseUrl == true ? endpoint : '$baseUrl/$endpoint'),
        headers: getHeaders());

    try {
      if (response.ok) {
        dynamic resp = jsonDecode(response.body);

        var m = pick(resp, 'message');
        return (resp, !m.isAbsent ? handleApiMessage(resp) : null);
      } else {
        String message =
            'An error occurred, we could not complete your request, try again later. error code : 0X0003';

        try {
          Map err = jsonDecode(response.body);
          return (null, handleApiMessage(err));
        } catch (e) {
          return (null, ApiResponseMessage(success: false, message: message));
        }
      }
    } catch (e) {
      return (
        null,
        ApiResponseMessage(
            success: false,
            message: "Unexpected issue occurred try again later")
      );
    }
  }

  Future<(dynamic, ApiResponseMessage?)> postRequest(
      String endpoint, Map<String, dynamic> data,
      {bool? noUseBaseUrl}) async {
    try {
      final response = await http.post(
        Uri.parse(noUseBaseUrl == true ? endpoint : '$baseUrl/$endpoint'),
        headers: getHeaders(),
        body: jsonEncode(data),
      );

      Map<String, dynamic> resp = jsonDecode(response.body);
      if (response.ok) {
        var m = pick(resp, 'message');

        return (resp, !m.isAbsent ? handleApiMessage(resp) : null);
      } else {
        String message = "Could not complete your request try again later.";

        try {
          Map err = json.decode(response.body);
          return (null, handleApiMessage(err));
        } catch (e) {
          return (null, ApiResponseMessage(success: false, message: message));
        }
      }
    } catch (e) {
      return (
        null,
        ApiResponseMessage(
            success: false,
            message: FancyErrorCodes.getErrorMessage(
                FancyErrorCodes.noInternetNebula))
      );
    }
  }

  ApiResponseMessage handleApiMessage(dynamic resp) {
    String message =
        'An error occurred, we could not complete your request, try again later. error code : 0X0002';

    bool isSuccess = pick(resp, 'success').asBoolOrFalse();

    var m = pick(resp, 'message').asStringOrNull();

    return ApiResponseMessage(success: isSuccess, message: m ?? message);
  }
}

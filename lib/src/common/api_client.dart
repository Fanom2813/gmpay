import 'dart:convert';
import 'package:either_dart/either.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/common/errors.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:map_enhancer/map_enhancer.dart';

class ApiClient {
  final String baseUrl;

  ApiClient(this.baseUrl);

  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'apiKey': '${Gmpay.instance.apiKey}',
      if (Gmpay.instance.secretKey != null) ...{
        'secret': '${Gmpay.instance.secretKey}',
      }
    };
  }

  Future<Either<Map<String, dynamic>?, ApiResponseMessage?>> getRequest(
      String endpoint) async {
    final response =
        await http.get(Uri.parse('$baseUrl/$endpoint'), headers: getHeaders());

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);

      if (resp.hasIn(['data', 'message']) || resp.hasIn(['message'])) {
        return Right(handleApiMessage(resp));
      }
      return Left(resp);
    } else {
      String message =
          'An error occurred, we could not complete your request, try again later. error code : 0X0003';

      try {
        Map err = json.decode(response.body);
        return Right(handleApiMessage(err));
      } catch (e) {
        return Right(ApiResponseMessage(success: false, message: message));
      }
    }
  }

  Future<Either<Map<String, dynamic>?, ApiResponseMessage?>> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: getHeaders(),
        body: jsonEncode(data),
      );

      Map<String, dynamic> resp = json.decode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          (resp['status'] == null ? true : resp['status'] == 200)) {
        if (resp.hasIn(['data', 'approval_url'])) {
          return Left(resp);
        }

        if (resp.hasIn(['data', 'message'])) {
          return Right(handleApiMessage(resp));
        }
        if (resp.hasIn(['message'])) {
          return Right(handleApiMessage(resp));
        }

        return Left(resp);
      } else {
        String message = "Could not complete your request try again later.";

        try {
          Map err = json.decode(response.body);
          return Right(handleApiMessage(err));
        } catch (e) {
          return Right(ApiResponseMessage(success: false, message: message));
        }
      }
    } catch (e) {
      return Right(ApiResponseMessage(
          success: false,
          message: FancyErrorCodes.getErrorMessage(
              FancyErrorCodes.noInternetNebula)));
    }
  }

  ApiResponseMessage handleApiMessage(Map<dynamic, dynamic> resp) {
    String message =
        'An error occurred, we could not complete your request, try again later. error code : 0X0002';

    bool? isSuccess;

    if (resp.hasIn(['data', 'message'])) {
      return ApiResponseMessage(
          success: true, message: resp.getIn(['data', 'message']));
    }

    if (resp.hasIn(['message'])) {
      message = resp.getIn(['message']);
    } else if (resp.hasIn(['error']) && resp.getIn(['error']) is String) {
      message = resp.getIn(['error']);
    } else if (resp.hasIn(['error', 'message'])) {
      message = resp.getIn(['error', 'message']);
    } else {
      message = resp.toString();
    }

    if (resp.hasIn(['success'])) {
      isSuccess = resp.getIn(['success']);
    }

    return ApiResponseMessage(success: isSuccess ?? false, message: message);
  }
}

import 'dart:convert';
import 'package:either_dart/either.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:map_enhancer/map_enhancer.dart';

class ApiClient {
  final String baseUrl; // Your API base URL

  ApiClient(this.baseUrl);

  Future<Either<Map<String, dynamic>?, ApiResponseMessage?>> getRequest(
      String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'apiKey': '${Gmpay.instance.apiKey}',
        if (Gmpay.instance.secretKey != null) ...{
          'secret': '${Gmpay.instance.secretKey}',
        }
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);

      if (resp.hasIn(['data', 'message'])) {
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
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'apiKey': '${Gmpay.instance.apiKey}',
        if (Gmpay.instance.secretKey != null) ...{
          'secret': '${Gmpay.instance.secretKey}',
        }
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);

      if (resp.hasIn(['data', 'approval_url'])) {
        return Left(resp);
      }

      if (resp.hasIn(['data', 'message'])) {
        return Right(handleApiMessage(resp));
      }
      return Left(resp);
    } else {
      String message =
          'An error occurred, we could not complete your request, try again later. error code : 0X0001';

      try {
        Map err = json.decode(response.body);
        return Right(handleApiMessage(err));
      } catch (e) {
        return Right(ApiResponseMessage(success: false, message: message));
      }
    }
  }

  ApiResponseMessage handleApiMessage(Map<dynamic, dynamic> resp) {
    String message =
        'An error occurred, we could not complete your request, try again later. error code : 0X0002';

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

    return ApiResponseMessage(success: false, message: message);
  }
}

import 'dart:convert';
import 'package:either_dart/either.dart';
import 'package:gmpay/flutter_gmpay.dart';
import 'package:gmpay/src/model/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:map_enhancer/map_enhancer.dart';

class ApiClient {
  final String baseUrl; // Your API base URL

  ApiClient(this.baseUrl);

  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load data');
    }
  }

  Future<Either<Map<String, dynamic>?, ApiResponseMessage?>> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'apiKey': '${Gmpay.instance.apiKey}',
        'secret': '${Gmpay.instance.secretKey}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> resp = json.decode(response.body);

      if (resp.hasIn(['data', 'approval_url'])) {
        return Left(resp);
      }

      if (resp.hasIn(['data', 'message'])) {
        return Right(ApiResponseMessage(
            success: true, message: resp.getIn(['data', 'message'])));
      }
      return Left(resp);
    } else {
      String message =
          'An error occurred, we could not complete your transaction, try again later. error code : 0X0001';

      try {
        Map err = json.decode(response.body);

        if (err.hasIn(['message'])) {
          message = err.getIn(['message']);
        } else if (err.hasIn(['error']) && err.getIn(['error']) is String) {
          message = err.getIn(['error']);
        } else if (err.hasIn(['error', 'message'])) {
          message = err.getIn(['error', 'message']);
        } else {
          message = err.toString();
        }

        return Right(ApiResponseMessage(success: false, message: message));
      } catch (e) {
        return Right(ApiResponseMessage(success: false, message: message));
      }
    }
  }
}

import 'package:http/http.dart';

extension HttpStatus on Response {
  bool get ok {
    return (statusCode ~/ 100) == 2;
  }
}

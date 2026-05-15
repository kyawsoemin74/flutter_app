import 'package:flutter/foundation.dart';
import 'package:football_xt_latest/constent.dart';
import 'package:http/http.dart' as http;

class ApiHelp {
  static var BASEURL = AppConfig.baseUrl;

  static Future<http.Response> get({required String ENDPOINTURL}) async {
    try {
      final url = Uri.parse('$BASEURL$ENDPOINTURL');
      final response = await http.get(url, headers: AppConfig.headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        debugPrint('Server Error (${response.statusCode}): ${response.body} at $ENDPOINTURL');
        return response;
      }
    } catch (e) {
      debugPrint('Network Error: $e');
      return http.Response('Connection Failed', 500);
    }
  }
}
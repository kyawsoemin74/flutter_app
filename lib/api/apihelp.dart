import 'package:flutter/foundation.dart';
import 'package:football_xt_latest/constent.dart';
import 'package:http/http.dart' as http;

class ApiHelp {
  static var BASEURL = AppConfig.baseUrl;

  static Future<http.Response> get({required String ENDPOINTURL}) async {
    try {
      var request = http.Request('GET', Uri.parse('$BASEURL$ENDPOINTURL'))
        ..headers.addAll({'Content-Type': 'application/json'});
      
      debugPrint('Requesting: $BASEURL$ENDPOINTURL');

      http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return http.Response.fromStream(response);
      } else {
        debugPrint('Server Error (${response.statusCode}): ${response.reasonPhrase} at $ENDPOINTURL');
        return http.Response('{"error": "Server Error", "status": ${response.statusCode}}', response.statusCode);
      }
    } catch (e) {
      debugPrint('Network Error: $e');
      return http.Response('Connection Failed', 500);
    }
  }
}
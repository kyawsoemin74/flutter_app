import 'package:flutter/foundation.dart';
import 'package:football_xt_latest/constent.dart';
import '../Custom_Model/leaguemathc.dart';
import '../api/apihelp.dart';

// final footballApiPlugin = FootballApi();

class HttpFixturmatch {
  Future<List<Leaguematch>> getFutureMatch({String? date}) async {
    List<Leaguematch> leaguematch = [];

    final String requestDate = date ?? DateTime.now().toIso8601String().split('T').first;

    final response = await ApiHelp.get(
      ENDPOINTURL: AppConfig.matchesByDateEndpoint(requestDate),
    );
    debugPrint("HttpFixturmatch response status: ${response.statusCode}");
    debugPrint("HttpFixturmatch response body length: ${response.body.length}");
    if (response.statusCode == 200) {
      debugPrint("HttpFixturmatch response body length: ${response.body.length}");
      leaguematch = await compute(
        parseAndGroupMatches,
        {'jsonString': response.body, 'status': null},
      );
      debugPrint("HttpFixturmatch grouped leaguematch length: ${leaguematch.length}");
    } else {
      debugPrint("HttpFixturmatch failed with status: ${response.statusCode}, body: ${response.body}");
    }

    return leaguematch;
  }
}

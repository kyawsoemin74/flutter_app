import 'package:flutter/foundation.dart';
import 'package:football_xt_latest/constent.dart';

import '../Custom_Model/leaguemathc.dart';
import '../api/apihelp.dart';
import '../model/MAtchlist/matchlist.dart';

class HttpLivematch {
  Future<List<Leaguematch>?> getlivematch() async {
    List<Leaguematch> leaguelive = [];
    try {
      // var data = await footballApiPlugin.getlivematch;
      var data = await ApiHelp.get(ENDPOINTURL: AppConfig.matchesLiveEndpoint);
      debugPrint("HttpLivematch response body length: ${data.body.length}");
      leaguelive = await compute(
        parseAndGroupMatches,
        {'jsonString': data.body, 'status': null},
      );
      debugPrint("HttpLivematch grouped leaguematch length: ${leaguelive.length}");
    } catch (e) {
      debugPrint("HttpLivematch getlivematch Error: ${e.toString()}");
    }
    return leaguelive;
  }

  Future<List<Matchlist>?> getalllivematch() async {
    List<Matchlist> leaguelive = [];
    try {
      // var data = await footballApiPlugin.getlivematch;
      var data = await ApiHelp.get(ENDPOINTURL: AppConfig.matchesLiveEndpoint);
      leaguelive = matchlistFromJson(data.body);
    } catch (e) {
      debugPrint(e.toString());
    }
    return leaguelive;
  }
}

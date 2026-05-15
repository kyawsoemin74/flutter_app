import 'package:flutter/foundation.dart';
import 'package:football_xt_latest/constent.dart';
import '../Custom_Model/leaguemathc.dart';
import '../api/apihelp.dart';


class Httprecentmatch {
  Future<List<Leaguematch>?> getrecentmatch({String? date}) async {
    List<Leaguematch> leaguematch = [];
    // var data = await footballApiPlugin.getfixturematchbydate(date: date!);
    var data = await ApiHelp.get(ENDPOINTURL: "/fixtures/date=$date");
    leaguematch = await compute(
      parseAndGroupMatches,
      {'jsonString': data.body, 'status': 'FT'},
    );
    return leaguematch;
  }
}

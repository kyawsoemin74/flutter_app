import 'dart:isolate';

import 'package:football_xt_latest/constent.dart';
import 'package:http/http.dart' as http;
import '../Custom_Model/leaguemathc.dart';
import '../api/apihelp.dart';
import '../model/MAtchlist/matchlist.dart';

// final footballApiPlugin = FootballApi();

class HttpFixturmatch {
  Future<List<Leaguematch>> getFutureMatch({String? date}) async {
    final ReceivePort receivePort = ReceivePort();
    List<Leaguematch> leaguematch = [];
    // var data = await footballApiPlugin.getfixturematchbydate(date: date!);
    var data = await ApiHelp.get(ENDPOINTURL: "${AppConfig.matchesEndpoint}/$date");
    var match = matchlistFromJson(data.body); // This line might still throw FormatException if API returns non-JSON
    await Isolate.spawn(
        matchfilterbyleague, [receivePort.sendPort, match, null]);
    leaguematch = await receivePort.first as List<Leaguematch>;
    return leaguematch;
  }
}

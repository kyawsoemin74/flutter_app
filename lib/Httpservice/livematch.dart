import 'dart:convert';
import 'dart:isolate';


import 'package:football_xt_latest/constent.dart';
import 'package:http/http.dart' as http;

import '../Custom_Model/leaguemathc.dart';
import '../api/apihelp.dart';
import '../model/MAtchlist/matchlist.dart';
import 'fixturematch.dart';

class HttpLivematch {
  Future<List<Leaguematch>?> getlivematch() async {
    List<Leaguematch> leaguelive = [];
    try {
      final ReceivePort receivePort = ReceivePort();
      // var data = await footballApiPlugin.getlivematch;
      var data = await ApiHelp.get(ENDPOINTURL: AppConfig.matchesLiveEndpoint);
      var match = matchlistFromJson(data.body);
      await Isolate.spawn(
          matchfilterbyleague, [receivePort.sendPort, match, null]);
      leaguelive = await receivePort.first as List<Leaguematch>;
    } catch (e) {
      print(e.toString());
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
      print(e.toString());
    }
    return leaguelive;
  }
}

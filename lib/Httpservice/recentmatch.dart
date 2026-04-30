import 'dart:isolate';
import 'package:football_xt_latest/constent.dart';
import '../Custom_Model/leaguemathc.dart';
import '../api/apihelp.dart';
import '../model/MAtchlist/matchlist.dart';


class Httprecentmatch {
  Future<List<Leaguematch>?> getrecentmatch({String? date}) async {
    final ReceivePort receivePort = ReceivePort();
    List<Leaguematch> leaguematch = [];
    // var data = await footballApiPlugin.getfixturematchbydate(date: date!);
    var data = await ApiHelp.get(ENDPOINTURL: "/fixtures/date=$date");
    var match = matchlistFromJson(data.body);
    await Isolate.spawn(
        matchfilterbyleague, [receivePort.sendPort, match, "FT"]);
    leaguematch = await receivePort.first as List<Leaguematch>;
    return leaguematch;
  }
}


import 'package:http/http.dart' as http;
import '../api/apihelp.dart';
import '../constent.dart';
import '../model/Headtohead/headtohead.dart';
import 'fixturematch.dart';

class Httph2h {
  Future<List<HeadtoHead>?> getheadtohead({int? matchid}) async {
//  var data =
//         await footballApiPlugin.getheadtohead(teamA: teamid1!, teamB: teamid2!);
    var data = await ApiHelp.get(
        ENDPOINTURL: AppConfig.matchH2HEndpoint(matchid.toString()));
    return headtoheadFromJson(data.body);
  }
}

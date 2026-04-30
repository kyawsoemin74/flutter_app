
import 'package:http/http.dart' as http;
import '../api/apihelp.dart';
import '../model/Headtohead/headtohead.dart';
import 'fixturematch.dart';

class Httph2h {
  Future<List<HeadtoHead>?> getheadtohead({int? teamid1, int? teamid2}) async {
//  var data =
//         await footballApiPlugin.getheadtohead(teamA: teamid1!, teamB: teamid2!);
    var data = await ApiHelp.get(
        ENDPOINTURL: "/fixtures/headtohead/h2h=$teamid2-$teamid1");
    return headtoheadFromJson(data.body);
  }
}

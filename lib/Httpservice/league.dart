
import 'package:http/http.dart' as http;
import '../api/apihelp.dart';
import '../constent.dart';
import '../model/All_League/all_league.dart';
import '../model/LeagueFixture/leaguefixture.dart';
import 'fixturematch.dart';

class HttpLeague {
  Future<List<Allleague>?> getallleague() async {
    // var data = await footballApiPlugin.getallleague;
    var data = await ApiHelp.get(ENDPOINTURL: "${AppConfig.leaguesEndpoint}/current=true");
    return allleagueFromJson(data.body);
  }

  Future<List<Leaguefixture>?> getleaguefixture(
      {int? leagueid, int? season}) async {
    var data = await ApiHelp.get(ENDPOINTURL: "${AppConfig.fixturesEndpoint}/league=$leagueid/season=$season");
    return leaguefixtureFromJson(data.body);
  }
}

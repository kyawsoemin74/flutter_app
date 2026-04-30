
import '../api/apihelp.dart';
import '../constent.dart';
import '../model/Standings/standings.dart';
import 'fixturematch.dart';

class Httpstanding {
  Future<List<Standings>?> getstanding({int? leagueid, int? season}) async {
    // var data =
    //   await footballApiPlugin.getstanding(league: leagueid!, season: season!);
    var data = await ApiHelp.get(ENDPOINTURL: "${AppConfig.standingsEndpoint}/league=$leagueid/season=$season");
    return standingsFromJson(data.body);
  }
}

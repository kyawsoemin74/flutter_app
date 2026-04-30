
import 'package:football_xt_latest/api/apihelp.dart';
import 'package:football_xt_latest/constent.dart';

import '../model/Top_Score/top_score.dart';

class Httptopscore {
  Future<List<TopScore>?> gettopscore({int? leagueid, int? season}) async {
    var data = await ApiHelp.get(ENDPOINTURL: "${AppConfig.topScoresEndpoint}/league=$leagueid/season=$season");
    return topScoreFromJson(data.body);
  }
}

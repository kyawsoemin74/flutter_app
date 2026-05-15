import 'dart:convert';
import 'package:football_xt_latest/constent.dart';
import '../api/apihelp.dart';
import '../model/Odd/odd.dart';

class HttpOdds {
  Future<List<Odd>?> getOdds(int fixtureid) async {
    final endpoint = AppConfig.matchOddsEndpoint(fixtureid.toString());
    final response = await ApiHelp.get(ENDPOINTURL: endpoint);
    if (response.statusCode == 200) {
      return oddFromJson(response.body);
    }
    return null;
  }
}

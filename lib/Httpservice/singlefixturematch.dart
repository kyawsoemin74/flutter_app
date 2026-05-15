

import 'dart:convert';
import '../api/apihelp.dart';
import '../constent.dart';
import '../model/SingleFixture/singlefixture.dart';


class HttpSinglefixture {
  Future<List<Singlefixture>?> getsinglefixture(int fixtureid) async {
    // var data = await footballApiPlugin.getfixturedetails(fixtureid: fixtureid);
    var data = await ApiHelp.get(ENDPOINTURL: AppConfig.matchDetailsEndpoint(fixtureid.toString()));
    if (data.statusCode == 200) {
      final decoded = jsonDecode(data.body);
      final list = decoded is List ? decoded : (decoded['data'] ?? decoded['result'] ?? []);
      if (list is List) {
        return list.map<Singlefixture>((x) => Singlefixture.fromJson(x)).toList();
      }
      print('HttpSinglefixture getsinglefixture: Expected List but got ${list.runtimeType}');
    }
    return null;
  }
}

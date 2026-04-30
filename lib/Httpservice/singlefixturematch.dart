

import '../api/apihelp.dart';
import '../model/SingleFixture/singlefixture.dart';


class HttpSinglefixture {
  Future<List<Singlefixture>?> getsinglefixture(int fixtureid) async {
    // var data = await footballApiPlugin.getfixturedetails(fixtureid: fixtureid);
    var data = await ApiHelp.get(ENDPOINTURL: "/fixtures/id=$fixtureid");
    return singlefixtureFromJson(data.body);
  }
}

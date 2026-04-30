import 'package:http/http.dart' as http;
import '../constent.dart';
import '../model/M3u8/livestream2.dart';

class HttpM3u8 {
  Future<List<LiveStream2>?> getlivestream2() async {
    var request = http.Request('GET', Uri.parse("https://zhazha.pw/api/live-links"));

    http.StreamedResponse response = await request.send();
    var responsedata = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      return liveStream2FromJson(responsedata.body);
    } else {
      print(response.reasonPhrase);
    }
  }
}

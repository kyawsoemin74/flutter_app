
import 'package:http/http.dart' as http;

import '../Ads_Code/ads_code.dart';
import '../model/Ads/ads.dart';

class HttpAds {
  Future<Ads?> getads() async {
    return Ads.fromJson(adsdata);
  }
}

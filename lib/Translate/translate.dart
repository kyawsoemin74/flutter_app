
import 'package:football_xt_latest/Translate/en_us.dart';
import 'package:football_xt_latest/Translate/khmer.dart';
import 'package:football_xt_latest/Translate/vietnam.dart';
import 'package:get/get.dart';

import 'brazil.dart';

class LocalString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        "en_Us": en_US,
        "km_KH": kn_KH,
        "vi_VI": vi_VI,
        "br_BR": br_BR,
      };
}

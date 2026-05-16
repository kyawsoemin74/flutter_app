import 'package:hive_flutter/hive_flutter.dart';

const String hiveAdsBoxName = 'ads';

bool _hiveInitialized = false;

Future<void> initHiveAdsStorage() async {
  if (!_hiveInitialized) {
    try {
      await Hive.initFlutter();
    } catch (_) {
      // Hive may already be initialized. Ignore initialization errors.
    }
    _hiveInitialized = true;
  }

  if (!Hive.isBoxOpen(hiveAdsBoxName)) {
    try {
      await Hive.openBox(hiveAdsBoxName);
    } catch (_) {
      // If Hive cannot open the box, continue without crashing.
    }
  }
}

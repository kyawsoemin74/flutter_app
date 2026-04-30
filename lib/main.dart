import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/constent.dart';
import 'package:football_xt_latest/splash.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_core/firebase_core.dart';//အသစ်ထည့်လိုက်တဲ့ import
import 'firebase_options.dart';  //အသစ်ထည့်လိုက်တဲ့ import

import 'package:provider/provider.dart';
import 'Provider/Ads/ads.dart';
import 'Provider/filterdate.dart';
import 'Provider/match.dart';
import 'Translate/translate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Hive.initFlutter(),
    MobileAds.instance.initialize(),
  ]);

  await Hive.openBox("ads");
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: ((context) => MatchProvider())),
    ChangeNotifierProvider(create: ((context) => Adsprovider())),
    ChangeNotifierProvider(create: ((context) => FilterDateProvider())),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: const Color(0xFF102a4a),
            primarySwatch: const MaterialColor(0xFF102a4a, {
              50: Color(0xFFE2E5E9),
              100: Color(0xFFB8C0C9),
              200: Color(0xFF8996A5),
              300: Color(0xFF5A6C81),
              400: Color(0xFF374D66),
              500: Color(0xFF102a4a),
              600: Color(0xFF0E2543),
              700: Color(0xFF0C1F3A),
              800: Color(0xFF0A1932),
              900: Color(0xFF060F22),
            }),
            textTheme: Typography.englishLike2018
                .apply(fontSizeFactor: 1.sp, bodyColor: Colors.white),
          ),
          home: child,
        );
      },
      child: const SplashScreenPage(),
    );
  }
}

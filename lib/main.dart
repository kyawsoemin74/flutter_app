import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/constent.dart';
import 'package:football_xt_latest/splash.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:provider/provider.dart';
import 'Provider/Ads/ads.dart';
import 'Provider/filterdate.dart';
import 'Provider/match.dart';
import 'Provider/news.dart';

void main() async {
  // 1. Flutter engine ကို အရင်နှိုးမယ်
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Data သိမ်းမယ့် Hive ကို စိတ်ချရအောင် await လုပ်မယ်
    await Hive.initFlutter();
    await Hive.openBox('ads');
  } catch (e) {
    debugPrint("Hive Error: $e"); // Error တက်ရင်လည်း App ဆက်ပွင့်အောင် လုပ်ထားတာပါ
  }

  // 3. MobileAds ကို background မှာပဲ ပစ်ထားမယ် (Hanging မဖြစ်အောင်)
  MobileAds.instance.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MatchProvider()),
      ChangeNotifierProvider(create: (_) => Adsprovider()),
      ChangeNotifierProvider(create: (_) => FilterDateProvider()),
      ChangeNotifierProvider(create: (_) => NewsProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            // --- ပြင်ဆင်လိုက်သော အနက်ရောင် Logic ---
            scaffoldBackgroundColor: const Color(0xFF000000), 
            primarySwatch: const MaterialColor(0xFF000000, {
              50: Color(0xFFE0E0E0),
              100: Color(0xFFBDBDBD),
              200: Color(0xFF9E9E9E),
              300: Color(0xFF757575),
              400: Color(0xFF616161),
              500: Color(0xFF000000), 
              600: Color(0xFF000000),
              700: Color(0xFF000000),
              800: Color(0xFF000000),
              900: Color(0xFF000000),
            }),
            // ------------------------------------
            textTheme: Typography.englishLike2018
                .apply(fontSizeFactor: 1.sp, bodyColor: Colors.white),
          ),
          home: child,
        );
      },
      child: const SplashScreenPage(), // splash ထဲက navigation logic ကိုလည်း ပြန်စစ်ပေးပါ
    );
  }
}
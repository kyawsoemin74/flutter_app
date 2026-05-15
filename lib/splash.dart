// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'Mainscreen/mainscreen.dart';
import 'Provider/Ads/ads.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _startAppLogic();
  }

  Future<void> _startAppLogic() async {
    // ၁။ UI ပေါ်လာအောင် ခဏစောင့်ပါ (ဥပမာ ၂ စက္ကန့်)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Trigger ads fetch in background - do not await
    final adsProvider = Provider.of<Adsprovider>(context, listen: false);
    adsProvider.loadAds().then((_) {
      // Initialize Facebook ads if enabled
      if (adsProvider.ads?.fb == 1) {
        EasyAudienceNetwork.init(iOSAdvertiserTrackingEnabled: true, testMode: false);
      }
    }).catchError((e) {
      debugPrint("Ads initialization failed: $e");
    });

    // Initialize OneSignal in background
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize("163ca135-48ad-4a4a-8471-687ef9ce2602");
      OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint("OneSignal initialization failed: $e");
    }

    // Navigate immediately to home screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MAinScreenpage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/image_2023_08_11T15_19_23_479Z.png",
          height: 70.h,
        ),
      ),
    );
  }
}

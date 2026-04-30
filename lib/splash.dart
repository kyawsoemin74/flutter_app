// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'Mainscreen/mainscreen.dart';
import 'Provider/Ads/ads.dart';
import 'Provider/match.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  Future loaddata() async {
    final ads = Provider.of<Adsprovider>(context, listen: false);
    await ads.getads(context);
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("163ca135-48ad-4a4a-8471-687ef9ce2602");
    OneSignal.Notifications.requestPermission(true);
    if (ads.ads!.google == 1) {
      MobileAds.instance.initialize();
    } else if (ads.ads!.fb == 1) {
      EasyAudienceNetwork.init(iOSAdvertiserTrackingEnabled: true, testMode: false);
    }
  }

  @override
  void initState() {
    loaddata().then((value) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => MAinScreenpage())));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset("assets/image_2023_08_11T15_19_23_479Z.png", height: 70.h)));
  }
}

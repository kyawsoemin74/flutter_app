// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:football_xt_latest/easy_audience_network_stub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'Mainscreen/mainscreen.dart';
import 'Provider/Ads/ads.dart';
import 'Provider/match.dart';
import 'hive_helpers.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAppLogic();
    });
  }

  Future<void> _startAppLogic() async {
    if (!mounted) return;

    final adsProvider = Provider.of<Adsprovider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    try {
      // SEQUENCE 1: Load ads first (non-blocking network call with timeout)
      unawaited(
        adsProvider.loadAds().then((_) async {
          if (!mounted || adsProvider.ads == null) return;
          if (adsProvider.ads?.fb == 1) {
            try {
              await EasyAudienceNetwork.init(
                iOSAdvertiserTrackingEnabled: true,
                testMode: false,
              );
            } catch (e) {
              debugPrint('FB ad init failed: $e');
            }
          }
        }).catchError((e) {
          debugPrint('Ads initialization failed: $e');
        }),
      );

      // SEQUENCE 2: Initialize OneSignal separately (doesn't need to await)
      unawaited(
        Future.microtask(() {
          try {
            OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
            OneSignal.initialize('163ca135-48ad-4a4a-8471-687ef9ce2602');
            OneSignal.Notifications.requestPermission(true);
          } catch (e) {
            debugPrint('OneSignal initialization failed: $e');
          }
        }),
      );

      // SEQUENCE 3: Schedule match fetch in background (happens AFTER navigation)
      // Do NOT await this - let it load after UI is visible
      unawaited(
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            if (!mounted) return;
            final todayDate = DateTime.now().toIso8601String().split('T').first;
            matchProvider.getfixturematch(date: todayDate).catchError((e) {
              debugPrint('Background match fetch failed: $e');
            });
          },
        ),
      );

      // Initialize Hive storage after the first visible frame, before navigating to main UI.
      await initHiveAdsStorage();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MAinScreenpage()),
      );
    } catch (e) {
      debugPrint('Splash startup error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MAinScreenpage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/image_2023_08_11T15_19_23_479Z.png',
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}

// Helper to fire-and-forget futures
void unawaited(Future<void> future) {}

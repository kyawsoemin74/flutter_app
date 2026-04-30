import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../Ads_Code/ads_code.dart';

import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class MatchSummaryPage extends StatefulWidget {
  const MatchSummaryPage({Key? key}) : super(key: key);

  @override
  State<MatchSummaryPage> createState() => _MatchSummaryPageState();
}

class _MatchSummaryPageState extends State<MatchSummaryPage> {
  double valueget({value1, value2, value}) {
    if (value.contains("%")) {
      var data = value.split("%").first;
      return (int.parse(data) / 100).toDouble();
    } else if (value.contains(".")) {
      return (double.parse(value) /
          (double.parse(value1 ?? 0) + double.parse(value2 ?? 0)));
    } else if (value1 == null || value2 == null || value == null) {
      return (int.parse("0") / (int.parse("0") + int.parse("0")));
    } else {
      int sum = (int.parse(value1) + int.parse(value2));
      if (value == "0") {
        return 0.0;
      } else {
        return (int.parse(value)) / sum;
      }
    }
  }
 InterstitialAd? _interstitialAd;
  fb.InterstitialAd? _fbinterstitialAd;
  int _numInterstitialLoadAttempts = 0;
  Future _createInterstitialAd() async {
     final provider = Provider.of<Adsprovider>(context, listen: false);
    InterstitialAd.load(
      adUnitId: provider.ads!.gInterstitial!,
      request: const AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (kDebugMode) {
            print('$ad loaded');
          }
          ad.show();
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;

          _createInterstitialAd();
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('Warning: attempt to show interstitial before loaded.');
      }
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('ad onAdShowedFullScreenContent.');
        }
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('$ad onAdDismissedFullScreenContent.');
        }
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  bool _fbisInterstitialAdLoaded = false;
  Future loadfbInterstitialAd() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final interstitialAd = fb.InterstitialAd(provider.ads!.fbInterstitial!);
    interstitialAd.listener = fb.InterstitialAdListener(
      onLoaded: () {
        print('interstitial ad loaded');
        _fbisInterstitialAdLoaded = true;
      },
      onError: (code, message) {
        print('interstitial ad error\ncode = $code\nmessage = $message');
      },
      onDismissed: () {
        interstitialAd.destroy();
        loadfbInterstitialAd();
      },
    );
    interstitialAd.load();
    _fbinterstitialAd = interstitialAd;
  }

  showfbInterstitialAd() {
    if (_fbisInterstitialAdLoaded == true) {
      _fbinterstitialAd!.show();
    } else if (kDebugMode) {
      print("Interstial Ad not yet loaded!");
    }
  }

  bool clickads() {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    var box = Hive.box('ads');
    int clickads = box.get('click') ?? 0;
    if (clickads % provider.ads!.adsClick! == 0) {
      if (kDebugMode) {
        print(true);
      }
      box.put('click', clickads + 1);
      return true;
    } else {
      if (kDebugMode) {
        print(false);
      }
      box.put('click', clickads + 1);
      return false;
    }
  }

  Future loadinterstitialads() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    if (provider.ads!.google == 1 && clickads() == true) {
      _createInterstitialAd();
    } else if (provider.ads!.fb == 1 && clickads() == true) {
      loadfbInterstitialAd().then((value) =>
          Future.delayed(Duration(seconds: 5), () => showfbInterstitialAd()));
    }
  }

  @override
  void initState() {loadinterstitialads();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchProvider>(context);
    return match.singlematch.first.statistics!.isEmpty
        ?  Center(
            child: Text(
              "No data Found".tr,
              style: TextStyle(color: Colors.white),
            ),
          )
        : ListView.builder(
            itemCount: match.singlematch.first.statistics!.first.statistics!.length,
            itemBuilder: ((context, index) {
              var data1 = match.singlematch.first.statistics!.first.statistics![index];
              var data2 = match.singlematch.first.statistics!.last.statistics![index];
              return Container(
                height: 50.h,
                color: index.isEven
                    ? Color(0xFF102a4a)
                    : Color(0xFF102a4a).withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data1.type!),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        SizedBox(width: 5.w),
                        Text("${data1.value ?? 0}"),
                        Expanded(
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 10.0,
                            animationDuration: 2500,
                            percent: valueget(
                                value1: "${data1.value ?? 0}",
                                value2: "${data2.value ?? 0}",
                                value: "${data1.value ?? 0}"),
                            barRadius: Radius.circular(5.r),
                          ),
                        ),
                        Expanded(
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 10.0,
                            animationDuration: 2500,
                            percent: valueget(
                                value1: "${data1.value ?? 0}",
                                value2: "${data2.value ?? 0}",
                                value: "${data2.value ?? 0}"),
                            barRadius: Radius.circular(5.r),
                          ),
                        ),
                        Text("${data2.value ?? 0}"),
                        SizedBox(width: 5.w),
                      ],
                    ),
                  ],
                ),
              );
            }));
  }
}

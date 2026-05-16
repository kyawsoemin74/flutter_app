import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../Ads_Code/ads_code.dart';

import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class HeadToHeadPage extends StatefulWidget {
  const HeadToHeadPage({Key? key}) : super(key: key);

  @override
  State<HeadToHeadPage> createState() => _HeadToHeadPageState();
}

class _HeadToHeadPageState extends State<HeadToHeadPage> {
  bool loading = false;

  Future loaddata() async {
    setState(() {
      loading = true;
    });
    final match = Provider.of<MatchProvider>(context, listen: false);
    final matchId = match.singleMatchData?.matchId;
    if (matchId != null) {
      await match.geth2h(matchid: matchId);
    }
    setState(() {
      loading = false;
    });
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
    final box = Hive.isBoxOpen('ads') ? Hive.box('ads') : null;
    final clickads = box?.get('click') ?? 0;
    if (clickads % provider.ads!.adsClick! == 0) {
      if (kDebugMode) {
        print(true);
      }
      box?.put('click', clickads + 1);
      return true;
    } else {
      if (kDebugMode) {
        print(false);
      }
      box?.put('click', clickads + 1);
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
  void initState() {
    super.initState();
    loadinterstitialads();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loaddata();
    });
  }

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchProvider>(context);
    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (match.h2h.isEmpty) {
      return Center(
        child: Text(
          "Head to Head not available".tr,
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   height: 41.h,
            //   width: 330.w,
            //   decoration: BoxDecoration(
            //       color: Color(0xFf2F2F39),
            //       borderRadius: BorderRadius.only(
            //           topLeft: Radius.circular(10.r),
            //           topRight: Radius.circular(10.r))),
            //   child: Text(
            //     "Head 2 Head Match",
            //     style: TextStyle(
            //       fontSize: 14.sp,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: match.h2h.length,
              itemBuilder: ((context, index) {
                var data = match.h2h[index];
                return Column(
                  children: [
                    Container(
                      height: 56.h,
                      width: 330.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    data.teams!.home['name'],
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                CircleAvatar(
                                    radius: 10.r,
                                    backgroundImage:
                                        NetworkImage(data.teams!.home['logo'])),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "${data.goals!.home ?? 0} - ${data.goals!.away ?? 0}",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                    radius: 10.r,
                                    backgroundImage:
                                        NetworkImage(data.teams!.away['logo'])),
                                SizedBox(width: 12.w),
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    data.teams!.away['name'],
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            )
          ],
        ),
      );
    }
  }
}

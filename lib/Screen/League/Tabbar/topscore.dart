import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import 'package:flutter/foundation.dart';
import '../../../constent.dart';
import '../../../model/Top_Score/top_score.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TopScorePage extends StatefulWidget {
  final int leagueid;
  final int season;
  const TopScorePage({Key? key, required this.leagueid, required this.season})
      : super(key: key);

  @override
  _TopScorePageState createState() => _TopScorePageState();
}

class _TopScorePageState extends State<TopScorePage> {
  // ads start

  bool loading = true;
  Future loaddata() async {
    await Provider.of<MatchProvider>(context, listen: false)
        .gettopscore(leagueid: widget.leagueid, season: widget.season);
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
  void initState() {
    loadinterstitialads();
    loaddata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MatchProvider>(context);
    return loading
        ? Center(
            child: CupertinoActivityIndicator(
              color: Colors.white,
            ),
          )
        : provider.topscore!.isEmpty
            ? Container()
            : Container(
                margin: EdgeInsets.all(5.r),
                child: ExpandedTileList.builder(
                  itemCount: provider.topscore!.length,
                  itemBuilder: (context, index, controller) {
                    var data = provider.topscore![index];
                    return ExpandedTile(
                      theme: ExpandedTileThemeData( // Changed to use AppConfig.glassEffectColor
                        headerColor: AppConfig.glassEffectColor,
                        

                        headerPadding: EdgeInsets.all(15),
                        headerSplashColor: Color(0xFF0B2959),
                        //
                        contentBackgroundColor: Colors.transparent,
                        contentPadding: EdgeInsets.all(5),
                       
                      ),
                      enabled: true,
                      title: Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(data.player!.photo!),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(data.player!.name!),
                        ],
                      ),
                      content: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: data.statistics!.length,
                          itemBuilder: ((context, index) {
                            var statis = data.statistics![index];
                            return Column(
                              children: [
                                leageinfo(statis),
                                game(statis),
                                substitutes(statis),
                                shots(statis),
                                goals(statis),
                                passes(statis),
                                tackles(statis),
                                dribbles(statis),
                                fouls(statis),
                                cards(statis),
                                penalty(statis),
                              ],
                            );
                          })),
                      controller: controller,
                    );
                  },
                ),
              );
  }

  Widget leageinfo(Statistic statis) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
        color: AppConfig.glassEffectColor,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(statis.league!.logo ?? ""),
              ),
              SizedBox(width: 10.w),
              Text(
                "League".tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(flex: 1, child: Text("Name".tr)),
              Expanded(flex: 2, child: Text(": ${statis.league!.name!}"))
            ],
          ),
          Row(
            children: [
              Expanded(flex: 1, child: Text("country".tr)),
              Expanded(
                  flex: 2, child: Text(": ${statis.league!.country ?? ""}"))
            ],
          ),
          Row(
            children: [
              Expanded(flex: 1, child: Text("season".tr)),
              Expanded(flex: 2, child: Text(": ${statis.league!.season ?? ""}"))
            ],
          )
        ],
      ),
    );
  }

  Widget game(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Game".tr),
          ),
          box(
              name: "appearences".tr,
              value: "${statis.games!.appearences ?? 0}"),
          box(name: "lineups".tr, value: "${statis.games!.lineups ?? 0}"),
          box(name: "minutes".tr, value: "${statis.games!.minutes ?? 0}"),
          box(name: "number".tr, value: "${statis.games!.number ?? 0}"),
          box(name: "position".tr, value: "${statis.games!.position ?? 0}"),
          box(name: "rating".tr, value: "${statis.games!.rating ?? 0}"),
          box(name: "captain".tr, value: "${statis.games!.captain ?? 0}"),
        ],
      ),
    );
  }

  Widget substitutes(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Substitutes".tr),
          ),
          box(
              name: "in".tr,
              value: "${statis.substitutes!.substitutesIn ?? 0}"),
          box(name: "out".tr, value: "${statis.substitutes!.out ?? 0}"),
          box(name: "bench".tr, value: "${statis.substitutes!.bench ?? 0}"),
        ],
      ),
    );
  }

  Widget shots(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Shots".tr),
          ),
          box(name: "total".tr, value: "${statis.shots!.total ?? 0}"),
          box(name: "on".tr, value: "${statis.shots!.on ?? 0}"),
        ],
      ),
    );
  }

  Widget goals(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Goals"),
          ),
          box(name: "total".tr, value: "${statis.goals!.total ?? 0}"),
          box(name: "conceded".tr, value: "${statis.goals!.conceded ?? 0}"),
          box(name: "assists".tr, value: "${statis.goals!.assists ?? 0}"),
          box(name: "saves".tr, value: "${statis.goals!.saves ?? 0}"),
        ],
      ),
    );
  }

  Widget passes(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Passes".tr),
          ),
          box(name: "total".tr, value: "${statis.passes!.total ?? 0}"),
          box(name: "key".tr, value: "${statis.passes!.key ?? 0}"),
          box(name: "accuracy".tr, value: "${statis.passes!.accuracy ?? 0}"),
        ],
      ),
    );
  }

  Widget tackles(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Tackles".tr),
          ),
          box(name: "total".tr, value: "${statis.tackles!.total ?? 0}"),
          box(name: "blocks".tr, value: "${statis.tackles!.blocks ?? 0}"),
          box(
              name: "interceptions".tr,
              value: "${statis.tackles!.interceptions ?? 0}"),
        ],
      ),
    );
  }

  Widget duels(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Duels".tr),
          ),
          box(name: "total".tr, value: "${statis.duels!.total ?? 0}"),
          box(name: "won".tr, value: "${statis.duels!.won ?? 0}"),
        ],
      ),
    );
  }

  Widget dribbles(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Dribbles".tr),
          ),
          box(name: "attempts".tr, value: "${statis.dribbles!.attempts ?? 0}"),
          box(name: "success".tr, value: "${statis.dribbles!.success ?? 0}"),
          box(name: "past".tr, value: "${statis.dribbles!.past ?? 0}"),
        ],
      ),
    );
  }

  Widget fouls(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Fouls".tr),
          ),
          box(name: "drawn".tr, value: "${statis.fouls!.drawn ?? 0}"),
          box(name: "committed".tr, value: "${statis.fouls!.committed ?? 0}"),
        ],
      ),
    );
  }

  Widget cards(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Cards".tr),
          ),
          box(name: "yellow".tr, value: "${statis.cards!.yellow ?? 0}"),
          box(name: "yellowred".tr, value: "${statis.cards!.yellowred ?? 0}"),
          box(name: "red".tr, value: "${statis.cards!.red ?? 0}"),
        ],
      ),
    );
  }

  Widget penalty(Statistic statis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration( // Changed to use AppConfig.glassEffectColor
          border: Border.all(color: AppConfig.glassEffectColor),
          borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            alignment: Alignment.centerLeft, // Changed to use AppConfig.glassEffectColor
            height: 50.h,
            width: double.infinity,
            color: AppConfig.glassEffectColor,
            child: Text("Penalty".tr),
          ),
          box(name: "won".tr, value: "${statis.penalty!.won ?? 0}"),
          box(name: "commited".tr, value: "${statis.penalty!.commited ?? 0}"),
          box(name: "scored".tr, value: "${statis.penalty!.scored ?? 0}"),
          box(name: "missed".tr, value: "${statis.penalty!.missed ?? 0}"),
          box(name: "saved".tr, value: "${statis.penalty!.saved ?? 0}"),
        ],
      ),
    );
  }

  Widget box({String? name, String? value}) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [Text(name!), Spacer(), Text("${value}")],
      ),
    );
  }
}

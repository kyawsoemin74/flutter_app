import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../../Ads_Code/ads_code.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import '../../../model/SingleFixture/singlefixture.dart';
import '../../Matchdetails/Tab/matchpreview.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class TimeLinePage extends StatefulWidget {
  final int teama;
  final int teamb;
  const TimeLinePage({Key? key, required this.teama, required this.teamb})
      : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<String> imagelist = [
    "Assets/Icon/image 20.png",
    "Assets/Icon/image 20.png",
    "Assets/Icon/image 20.png",
    "Assets/Icon/image 20.png"
  ];

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
    match.singlematch.first.events!.sort(
      (a, b) => b.time!.elapsed!.compareTo(a.time!.elapsed!),
    );
    return SingleChildScrollView(
      child: Column(
        children: [
          match.singlematch.first.events!.isEmpty
              ? Container()
              : Column(
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
                    //     "Timeline",
                    //     style: TextStyle(
                    //         fontSize: 14.sp,
                    //         fontWeight: FontWeight.w500,
                    //         ),
                    //   ),
                    // ),
                    Container(
                      width: 330.w,
                      decoration: BoxDecoration(color: Color(0xFF102a4a)),
                      child: Column(
                        children: [
                          // Text(
                          //   "Start",
                          //   style: TextStyle(
                          //       fontSize: 12.sp,
                          //       fontWeight: FontWeight.w500,
                          //       color: Color(0xFFA2A2AA)),
                          // ),
                          // SizedBox(height: 8.h),
                          Container(
                            width: 58.w,
                            height: 1.h,
                            color: Color(0xFF102a4a),
                          ),
                          ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var data =
                                    match.singlematch.first.events![index];
                                return Container(
                                  margin: EdgeInsets.all(10.r),
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                      color: index.isOdd
                                          ? Color(0xFF102a4a).withOpacity(0.5)
                                          : Color(0xFF102a4a),
                                      borderRadius:
                                          BorderRadius.circular(10.r)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: leftsidedata(data)),
                                      CircleAvatar(
                                          radius: 15.w,
                                          child: Text(
                                            "${data.time!.elapsed}''",
                                            style: TextStyle(fontSize: 12.sp),
                                          )),
                                      Expanded(child: rigthsidedata(data)),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 20.h,
                                      width: 1.w,
                                      color: Colors.white,
                                    ),
                                  ],
                                );
                              },
                              itemCount:
                                  match.singlematch.first.events!.length),
                        ],
                      ),
                    )
                  ],
                ),
          MAtchPreviewPage(),
        ],
      ),
    );
  }

  Widget leftsidedata(Event data) {
    if (data.team!.id == widget.teama) {
      if (data.type == 'Goal') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              data.player!.name ?? "",
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(width: 10.w),
            Image.asset(
              "assets/ball.png",
              height: 20.h,
              color: Colors.white,
            ),
            SizedBox(width: 10.w),
          ],
        );
      } else if (data.type == 'Card') {
        if (data.detail == "Yellow Card") {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                data.player!.name ?? "",
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(width: 10.w),
              Image.asset(
                "assets/yellow-card.png",
                height: 30.h,
              ),
              SizedBox(width: 10.w),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                data.player!.name ?? "",
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(width: 10.w),
              Image.asset(
                "assets/red.png",
                height: 30.h,
              ),
              SizedBox(width: 10.w),
            ],
          );
        }
      } else if (data.type == 'subst') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.player!.name ?? "",
                  style: TextStyle(fontSize: 12.sp),
                ),
                Text(
                  data.assist!.name ?? "",
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            Image.asset(
              "assets/change.png",
              height: 30.h,
            ),
            SizedBox(width: 10.w),
          ],
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  Widget rigthsidedata(Event data) {
    if (data.team!.id == widget.teamb) {
      if (data.type == 'Goal') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10.w),
            Image.asset(
              "assets/ball.png",
              height: 20.h,
              color: Colors.white,
            ),
            SizedBox(width: 10.w),
            Text(
              data.player!.name ?? "",
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        );
      } else if (data.type == 'Card') {
        if (data.detail == "Yellow Card") {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10.w),
              Image.asset(
                "assets/yellow-card.png",
                height: 30.h,
              ),
              SizedBox(width: 10.w),
              SizedBox(width: 10.w),
              Text(
                data.player!.name ?? "",
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10.w),
              Image.asset(
                "assets/red.png",
                height: 30.h,
              ),
              SizedBox(width: 10.w),
              Text(
                data.player!.name ?? "",
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          );
        }
      } else if (data.type == 'subst') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10.w),
            Image.asset(
              "assets/change.png",
              height: 30.h,
            ),
            SizedBox(width: 10.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.player!.name ?? "",
                  style: TextStyle(fontSize: 12.sp),
                ),
                Text(
                  data.assist!.name ?? "",
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ],
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }
}

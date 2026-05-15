import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import '../../../model/SingleFixture/singlefixture.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class LineUpPage extends StatefulWidget {
  const LineUpPage({Key? key}) : super(key: key);

  @override
  _LineUpPageState createState() => _LineUpPageState();
}

class _LineUpPageState extends State<LineUpPage> {
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

    if (match.singlematch.isEmpty || match.singlematch.first.lineups == null) {
      return Center(
        child: Text(
          "No data Found".tr,
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: match.singlematch.first.lineups!.isEmpty
          ? Center(
              child: Text(
                "No data Found".tr,
                style: TextStyle(color: Colors.white),
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/playground.png', fit: BoxFit.cover),
                match.singlematch.first.lineups!.first.formation != null
                    ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            lineupdraw(match.singlematch.first.lineups),
                            SizedBox(height: 30.h),
                            secoundlineupdrasw(match.singlematch.first.lineups),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
    );
  }

  Widget lineupdraw(List<Lineups>? value) {
    var formetdata = value!.first.formation!.split("-");
    formetdata.insert(0, '1');
    return Column(
      children: List.generate(formetdata.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40.h,
                child: ListView.builder(
                  itemCount: int.parse(formetdata[index]),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, rowindex) {
                    return SizedBox(
                      width: 70.w,
                      child: Lineupplayer(
                        value: value,
                        columindex: index,
                        rowindex: rowindex,
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget secoundlineupdrasw(List<Lineups>? value) {
    var formetdata = value!.last.formation!.split("-");
    formetdata.insert(0, '1');
    var reversdata = formetdata.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        reversdata.length,
        (index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            height: 40.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40.h,
                  child: ListView.builder(
                    reverse: true,
                    itemCount: int.parse(reversdata[index]),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, rowindex) {
                      return SizedBox(
                        width: 70.w,
                        child: Secoundlineupplayer(
                          value: value,
                          columindex: index,
                          rowindex: rowindex,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class Lineupplayer extends StatefulWidget {
  final List<Lineups>? value;
  final int columindex;
  final int rowindex;
  const Lineupplayer(
      {Key? key,
      required this.columindex,
      required this.rowindex,
      required this.value})
      : super(key: key);

  @override
  _LineupplayerState createState() => _LineupplayerState();
}

class _LineupplayerState extends State<Lineupplayer> {
  String? lineupgrid;
  @override
  void initState() {
    lineupgrid = '${widget.columindex + 1}:${widget.rowindex + 1}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.value!.first.startXi!
        .where((element) => element.player!.grid == lineupgrid)
        .toList();
    return SizedBox(
      height: 40.h,
      child: Column(
        children: [
          // Image.asset(
          //   'assets/lineup_img.png',
          //   height: 30,
          // ),
          CircleAvatar(
              radius: 12.r,
              backgroundImage: AssetImage("images/playertimage.png"),
              backgroundColor: Colors.transparent,
              child: Text(
                "${data.isEmpty ? "0" : data.first.player!.number ?? 0}",
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              )),
          Text(
            data.first.player!.name!,
            textAlign: TextAlign.center,
            maxLines: 1,
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
          )
        ],
      ),
    );
  }
}

class Secoundlineupplayer extends StatefulWidget {
  final List<Lineups>? value;
  final int columindex;
  final int rowindex;
  const Secoundlineupplayer(
      {Key? key,
      required this.columindex,
      required this.rowindex,
      required this.value})
      : super(key: key);

  @override
  _SecoundlineupplayerState createState() => _SecoundlineupplayerState();
}

class _SecoundlineupplayerState extends State<Secoundlineupplayer> {
  String? lineupgrid;
  @override
  void initState() {
    lineupgrid = '${widget.columindex + 1}:${widget.rowindex + 1}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.value!.last.startXi!
        .where((element) => element.player!.grid == lineupgrid)
        .toList();

    return SizedBox(
      height: 50.h,
      width: 150.w,
      child: Column(
        children: [
          CircleAvatar(
              radius: 12.r,
              backgroundImage: AssetImage("images/playertimage.png"),
              backgroundColor: Colors.transparent,
              child: Text(
                "${data.isEmpty ? "0" : data.first.player!.number ?? 0}",
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              )),
          data.isEmpty
              ? Text(
                  "Not Listed".tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                )
              : Text(
                  data.first.player!.name ?? "",
                  maxLines: 1,
                  // overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                )
        ],
      ),
    );
  }
}

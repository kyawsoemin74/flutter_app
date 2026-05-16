import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../../../../Ads_Code/ads_code.dart';
import '../../../../../Provider/Ads/ads.dart';
import '../../../../../Provider/match.dart';
import '../../../../../constent.dart';
import '../../../../Matchdetails/matchdetails.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class FutureMatchPage extends StatefulWidget {
  final int leagueid;
  final int season;
  const FutureMatchPage(
      {Key? key, required this.leagueid, required this.season})
      : super(key: key);

  @override
  State<FutureMatchPage> createState() => _FutureMatchPageState();
}

class _FutureMatchPageState extends State<FutureMatchPage> {
  bool loading = false;


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
loadinterstitialads();
    loading = true;
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final livematch = Provider.of<MatchProvider>(context);
    var futureleague = livematch.leaguefixture
        .where((element) =>
            element.fixture!.status!.short == "NS" ||
            element.fixture!.status!.short == "TBD")
        .toList();
    futureleague
        .sort((a, b) => a.fixture!.timestamp!.compareTo(b.fixture!.timestamp!));
    return CustomScrollView(
      slivers: [
        futureleague.isEmpty
            ? const SliverToBoxAdapter()
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var data = futureleague[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                  matchId: data.fixture!.id!),
                            ));
                      },
                      child: Container(
                        height: 50.h,
                        margin: const EdgeInsets.only(
                            left: 5, right: 5, bottom: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5), // Changed to use AppConfig.glassEffectColor
                          color: AppConfig.glassEffectColor,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 70.w,
                                      child: Text(
                                        data.teams!.home['name'],
                                        maxLines: 1,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: 25.w,
                                      height: 25.h,
                                      child: Image.network(
                                        data.teams!.home['logo'],
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    data.fixture!.status!.short == "TBD"
                                        ? Text(data.fixture!.status!.short!)
                                        : Text(
                                            data.fixture!.date?.toIso8601String() ?? '',
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                    Text(
                                      data.fixture!.date?.toIso8601String() ?? '',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )
                                  ],
                                )),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 25.w,
                                    height: 25.h,
                                    child: Image.network(
                                      data.teams!.away['logo'],
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 70.w,
                                    child: Text(
                                      data.teams!.away['name'],
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: futureleague.length,
                ),
              ),
      ],
    );
  }
}

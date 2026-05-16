import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import '../../../constent.dart';
import '../../../model/All_League/all_league.dart';
import '../leaguedetails.dart';
import 'package:flutter/foundation.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AllleaguePage extends StatefulWidget {
  const AllleaguePage({Key? key}) : super(key: key);

  @override
  _AllleaguePageState createState() => _AllleaguePageState();
}

class _AllleaguePageState extends State<AllleaguePage> {
  List<Allleague>? secoundleague = [];
  List<Allleague>? searchallleague = [];

  bool showsearchfield = false;

  void search(String value) {
    setState(() {
      searchallleague = secoundleague!
          .where(
              (element) => element.league!.name!.toLowerCase().contains(value))
          .toList();
    });
  }


  bool loading = false;

  Future loaddata() async {
    setState(() {
      loading = true;
    });
    // await Provider.of<MatchProvider>(context, listen: false).getallleague();
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
  void initState() {loadinterstitialads();
    loaddata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final livematch = Provider.of<MatchProvider>(context);
    secoundleague!.clear();
    secoundleague!.addAll(livematch.allleague);
    if (searchallleague!.isEmpty) {
      searchallleague!.clear();
      searchallleague!.addAll(livematch.allleague);
    }
    return Scaffold(
      appBar: AppBar(
        title: showsearchfield ? searchtextfield() : Text("All League".tr),
        actions: [
          showsearchfield
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showsearchfield = false;
                    });
                  },
                  icon: const Icon(Icons.close))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      showsearchfield = true;
                    });
                  },
                  icon: const Icon(Icons.search))
        ],
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(color: Colors.white,),
            )
          : CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var data = searchallleague![index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => LeaguedetailsPage(
                                      adsenable: 1,
                                      leagueid: data.league!.id!,
                                      season: data.seasons!.last.year!,
                                      leaguename: data.league!.name!,
                                    )),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppConfig.glassEffectColor,
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: data.league!.logo != null
                                      ? Image.network(
                                          data.league!.logo!,
                                          height: 30,
                                        )
                                      : Container(),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    "${data.league!.name!} - ${data.country!.name}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }, childCount: searchallleague!.length),
                )
              ],
            ),
    );
  }

  Widget searchtextfield() {
    return TextFormField(
      autofocus: true,
      onChanged: (value) {
        if (value.isNotEmpty) {
          search(value);
        } else {
          setState(() {
            searchallleague = secoundleague;
          });
        }
      },
      decoration: InputDecoration(
        hintText: "Search League".tr,
        border: InputBorder.none,
      ),
    );
  }
}

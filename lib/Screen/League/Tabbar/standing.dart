import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:football_xt_latest/constent.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:provider/provider.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import '../../../model/Standings/standings.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class StandingPage extends StatefulWidget {
  final int leagueid;
  final int season;
  const StandingPage({Key? key, required this.leagueid, required this.season})
      : super(key: key);

  @override
  _StandingPageState createState() => _StandingPageState();
}

class _StandingPageState extends State<StandingPage> {
  bool loading = true;

  Future loaddata() async {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    await provider.getstanding(
        leagueid: widget.leagueid, season: widget.season);
    setState(() {
      loading = false;
    });
  }

// ads start
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

    // loadinterstitialads();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final livematch = Provider.of<MatchProvider>(context);
    return loading
        ? const Center(
            child: CupertinoActivityIndicator(
              color: Colors.white,
            ),
          )
        : livematch.standing.isEmpty
            ? Center(
                child: Text(
                  "No data Found".tr,
                  style: TextStyle(color: Colors.white),
                ),
              )
            : DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    filter(),
                    // Divider(color: Colors.grey, height: 0),
                    // Flexible(child: datatablelist()),
                    Flexible(
                        child: TabBarView(children: [
                      datatablelist(0),
                      datatablelist(1),
                      datatablelist(2)
                    ])),
                  ],
                ),
              );
  }

  Widget allstanding(Standing data) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                data.team!.logo!,
                height: 25,
              ),
              const SizedBox(width: 10),
              Text(data.team!.name!),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: Text("${data.points ?? 0}")),
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: Text("${data.goalsDiff ?? 0}")),
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: Text("${data.rank ?? 0}"))
                ],
              )
            ],
          ),
          const Divider()
        ],
      ),
    );
  }

  Widget filter() {
    return TabBar(isScrollable: true, tabs: [
      Tab(text: "All".tr),
      Tab(text: "Home".tr),
      Tab(text: "Away".tr),
    ]);
  }

  Widget datatablelist(int index2) {
    final controller = Provider.of<MatchProvider>(context);
    return controller.standing.isEmpty
        ? Center(
            child: Text("Empty".tr),
          )
        : ListView.builder(
            itemCount: controller.standing.first.league!.standings!.length,
            itemBuilder: (context, index) {
              var data1 = controller.standing.first.league!.standings![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card( // Changed to use AppConfig.glassEffectColor
                  color: AppConfig.glassEffectColor,
                  child: DataTable(
                    columnSpacing: 0,
                    horizontalMargin: 0,
                    columns: [
                      DataColumn(
                          label: Text(
                              "     ${controller.standing.first.league!.name!}")),
                      DataColumn(label: Text("MP".tr)),
                      DataColumn(label: Text("+/-".tr)),
                      DataColumn(label: Text("GD".tr)),
                      DataColumn(label: Text("PTS".tr)),
                    ],
                    rows: List.generate(data1.length, (index) {
                      var data2 = data1[index];
                      All? all;
                      if (index2 == 0) {
                        all = data2.all;
                      } else if (index2 == 1) {
                        all = data2.home;
                      } else {
                        all = data2.away;
                      }
                      return DataRow(cells: [
                        DataCell(Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 3,
                            ),
                            Text(data2.rank.toString()),
                            SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 10,
                              backgroundImage: NetworkImage(data2.team!.logo!),
                            ),
                            SizedBox(width: 10),
                            Text(data2.team!.name!)
                          ],
                        )),
                        DataCell(Row(
                          children: [Text(all!.played.toString())],
                        )),
                        DataCell(Row(
                          children: [
                            Text("${all.goals!.goalsFor}-${all.goals!.against}")
                          ],
                        )),
                        DataCell(Row(
                          children: [
                            Text(
                                "${all.goals!.goalsFor ?? 0 - all.goals!.against! ?? 0}")
                          ],
                        )),
                        DataCell(Row(
                          children: [Text("${(all.win! * 3) + all.draw!}")],
                        ))
                      ]);
                    }),
                  ),
                ),
              );
            },
          );
  }

  Widget botton({String? text, GestureTapCallback? onTap, Color? color}) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(50)),
          child: Text(
            text!,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Provider/Ads/ads.dart';
import '../../Provider/filterdate.dart';
import '../../Provider/match.dart';
import '../LiveMatch/livematch2.dart';
import 'Fixture/todaymatch.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class Matchspage extends StatefulWidget {
  const Matchspage({Key? key}) : super(key: key);

  @override
  State<Matchspage> createState() => _MatchspageState();
}

class _MatchspageState extends State<Matchspage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  DateTime _selectdate = DateTime.now();
  TabController? tabController;

  void loaddate(DateTime dateTime) {
    final filterdate = Provider.of<FilterDateProvider>(context, listen: false);
    filterdate.generatetab(dateTime);
    tabController = TabController(
        length: filterdate.datetime.length, vsync: this, initialIndex: 3);
  }

  Future loadmatchdata(DateTime dateTime) async {
    Provider.of<MatchProvider>(context, listen: false).gettodayfixturematch(
        date: DateFormat("yyyy-MM-dd")
            .format(DateTime(dateTime.year, dateTime.month, dateTime.day)));
    Provider.of<MatchProvider>(context, listen: false).getfixturematch(
        date: DateFormat("yyyy-MM-dd")
            .format(DateTime(dateTime.year, dateTime.month, dateTime.day)));
  }

  bool live = false;
  bool loading = true;

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
    loaddate(_selectdate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filterdate = Provider.of<FilterDateProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(""),
        actions: [
          IconButton(
              onPressed: () {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2024))
                    .then((value) {
                  if (value != null) {
                    setState(() {
                      _selectdate = value;
                      loadmatchdata(value);
                      tabController!.animateTo(3,
                          curve: Curves.easeIn,
                          duration: const Duration(milliseconds: 500));
                      loaddate(value);
                    });
                  }
                });
              },
              icon: const Icon(Icons.calendar_month)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 10.w),
                child: AnimatedToggleSwitch<bool>.size(
                  current: live,
                  values: const [false, true],
                  iconOpacity: 0.1,
                  height: 30.h,
                  indicatorSize: Size.fromWidth(40.w),
                  // borderRadius: BorderRadius.circular(10.r),
                  iconBuilder: (value) {
                    String data = "Live".tr;
                    if (!value) data = "Off".tr;
                    return Center(
                      child: Text(
                        data,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.sp),
                      ),
                    );
                  },
                  // borderColor: live == false ? Colors.grey[700] : Colors.red,
                  // colorBuilder: (i) =>
                  //     i == false ? Colors.grey[800] : Colors.red,
                  onChanged: (p0) {
                    setState(() {
                      live = p0;
                      tabController!.animateTo(3,
                          curve: Curves.easeIn,
                          duration: const Duration(milliseconds: 500));
                    });
                  },
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          tabs: List.generate(
              filterdate.datetime.length,
              (index) => Tab(
                    child: Text(DateFormat("dd MMM")
                        .format(filterdate.datetime[index])),
                  )),
          controller: tabController,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: List.generate(
          filterdate.datetime.length,
          (index) => index == 3
              ? live == true
                  ? const LiveMatch2()
                  : TodayMatchPage(dateTime: filterdate.datetime[index])
              : TodayMatchPage(dateTime: filterdate.datetime[index]),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

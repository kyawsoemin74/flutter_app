import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;

import '../../Provider/Ads/ads.dart';
import '../../Provider/filterdate.dart';
import '../../Provider/match.dart';
import '../LiveMatch/livematch2.dart';
import 'Fixture/todaymatch.dart';

const List<String> _monthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String _formatShortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${_monthAbbreviations[date.month - 1]}';
}

String _formatIsoDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

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
    final requestDate = _formatIsoDate(DateTime(dateTime.year, dateTime.month, dateTime.day));
    // ONLY call getfixturematch - it loads all fixtures for the day
    // Do NOT call gettodayfixturematch - redundant duplicate load
    Provider.of<MatchProvider>(context, listen: false).getfixturematch(date: requestDate);
  }

  bool live = false;
  bool loading = true;

 InterstitialAd? _interstitialAd;
  fb.InterstitialAd? _fbinterstitialAd;
  int _numInterstitialLoadAttempts = 0;
  bool _isDisposed = false;
  static const int _maxAdRetries = 2;

  Future _createInterstitialAd() async {
    if (_isDisposed || _numInterstitialLoadAttempts >= _maxAdRetries) {
      return;
    }
    if (!mounted) return;

    final provider = Provider.of<Adsprovider?>(context, listen: false);
    final String? gInterstitialId = provider?.ads?.gInterstitial;
    if (gInterstitialId == null || gInterstitialId.isEmpty) return;

    InterstitialAd.load(
      adUnitId: gInterstitialId,
      request: const AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (_isDisposed || !mounted) {
            ad.dispose();
            return;
          }
          if (kDebugMode) {
            print('$ad loaded');
          }
          ad.show();
          _numInterstitialLoadAttempts = 0;
          _interstitialAd = ad;
          try {
            _interstitialAd!.setImmersiveMode(true);
          } catch (e) {
            debugPrint('Immersive mode error: $e');
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;

          // Only retry up to max attempts
          if (_numInterstitialLoadAttempts < _maxAdRetries && !_isDisposed) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null || _isDisposed) {
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
        if (!_isDisposed && mounted) {
          _createInterstitialAd();
        }
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        if (!_isDisposed && mounted) {
          _createInterstitialAd();
        }
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  bool _fbisInterstitialAdLoaded = false;
  Future loadfbInterstitialAd() async {
    if (_isDisposed || !mounted) return;

    final provider = Provider.of<Adsprovider>(context, listen: false);
    final fbInterstitialId = provider.ads?.fbInterstitial;
    if (fbInterstitialId == null) return;

    final interstitialAd = fb.InterstitialAd(fbInterstitialId);
    interstitialAd.listener = fb.InterstitialAdListener(
      onLoaded: () {
        if (_isDisposed || !mounted) return;
        print('interstitial ad loaded');
        _fbisInterstitialAdLoaded = true;
      },
      onError: (code, message) {
        print('interstitial ad error\ncode = $code\nmessage = $message');
      },
      onDismissed: () {
        interstitialAd.destroy();
        if (!_isDisposed && mounted) {
          loadfbInterstitialAd();
        }
      },
    );
    interstitialAd.load();
    _fbinterstitialAd = interstitialAd;
  }

  showfbInterstitialAd() {
    if (_fbisInterstitialAdLoaded == true && !_isDisposed) {
      _fbinterstitialAd!.show();
    } else if (kDebugMode) {
      print("Interstial Ad not yet loaded!");
    }
  }

  bool clickads() {
    final provider = Provider.of<Adsprovider?>(context, listen: false);
    final box = Hive.isBoxOpen('ads') ? Hive.box('ads') : null;
    final clickads = box?.get('click') ?? 0;
    final int adsClick = provider?.ads?.adsClick ?? 1;
    if (adsClick == 0) {
      // avoid modulo by zero
      box?.put('click', clickads + 1);
      return false;
    }
    if (clickads % adsClick == 0) {
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
    if (_isDisposed || !mounted) return;

    final provider = Provider.of<Adsprovider>(context, listen: false);
    if (provider.ads == null) return;

    if (provider.ads!.google == 1 && clickads() == true) {
      _createInterstitialAd();
    } else if (provider.ads!.fb == 1 && clickads() == true) {
      await loadfbInterstitialAd();
      if (!_isDisposed && mounted) {
        await Future.delayed(Duration(seconds: 5));
        if (!_isDisposed && mounted) {
          showfbInterstitialAd();
        }
      }
    }
  }

  @override
  void initState() {
    _isDisposed = false;
    // Schedule ad load after UI is ready, not blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        loadinterstitialads();
      }
    });

    loaddate(_selectdate);
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _interstitialAd?.dispose();
    _fbinterstitialAd?.destroy();
    super.dispose();
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
                    child: Text(_formatShortDate(filterdate.datetime[index])),
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

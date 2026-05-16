// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Provider/Ads/ads.dart';
import '../../Provider/match.dart';
import 'Tabbar/Fixture/Tabbar/futurematch.dart';
import 'Tabbar/Fixture/Tabbar/recentmatch.dart';
import 'Tabbar/standing.dart';
import 'Tabbar/topscore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LeaguedetailsPage extends StatefulWidget {
  final int adsenable;
  final int leagueid;
  final int season;
  final String leaguename;
  final bool adsshow;
  const LeaguedetailsPage(
      {Key? key,
      required this.leagueid,
      required this.season,
      required this.leaguename,
      this.adsshow = true,
      this.adsenable = 0})
      : super(key: key);

  @override
  _LeaguedetailsPageState createState() => _LeaguedetailsPageState();
}

class _LeaguedetailsPageState extends State<LeaguedetailsPage> {
// ads end

  Future loaddata() async {
    // await Provider.of<MatchProvider>(context, listen: false)
    //     .getleaguefixture(leagueid: widget.leagueid, season: widget.season);
    // await Provider.of<MatchProvider>(context, listen: false)
    //     .getstanding(leagueid: widget.leagueid, season: widget.season);
  }

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  Widget currentAd = const SizedBox(
    height: 0,
    width: 0,
  );
  Future<void> _loadAd() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: provider.ads!.gBanner!,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  Widget _showfbBannerAd(BuildContext context) {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    return fb.BannerAd(
      placementId: provider.ads!.fbBanner!,
      bannerSize: fb.BannerSize.STANDARD,
      listener: fb.BannerAdListener(
        onClicked: () {
          print("Banner Ad: click");
        },
        onError: (code, message) {
          print("Banner Ad: $code -->  $message");
        },
        onLoaded: () {
          setState(() {
            _isLoaded = true;
          });
          print("Banner Ad: loaded");
        },
        onLoggingImpression: () {
          print("Banner Ad: impression");
        },
      ),
    );
  }

  // facebook ads end

  Future loadads() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    if (provider.ads!.fb == 1) {
      currentAd = _showfbBannerAd(context);
    } else {
      currentAd = const SizedBox(
        height: 0,
        width: 0,
      );
    }
    setState(() {});
  }

  Widget bannerads() {
    return Container(
      color: Colors.transparent,
      width: _anchoredAdaptiveAd!.size.width.toDouble(),
      height: _anchoredAdaptiveAd!.size.height.toDouble(),
      child: AdWidget(ad: _anchoredAdaptiveAd!),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<Adsprovider>(context, listen: false);
    if (provider.ads!.google == 1) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }

  @override
  void initState() {
    loadads();
    loaddata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Adsprovider>(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        bottomNavigationBar: provider.ads!.fb == 1
            ? currentAd
            : provider.ads!.google == 1
                ? _isLoaded
                    ? bannerads()
                    : SizedBox()
                : SizedBox(),
        appBar: AppBar(
          toolbarHeight: 55,
          title: Text(widget.leaguename),
          bottom: TabBar(
            onTap: (value) {},
            tabs: [
              Tab(
                child: Text("Fixture".tr),
              ),
              Tab(
                child: Text("Recent".tr),
              ),
              Tab(
                child: Text("Standings".tr),
              ),
              Tab(
                child: Text("Top Score".tr),
              ),
            ],
            isScrollable: true,
          ),
        ),
        body: TabBarView(children: [
          // LiveMatchPage(leagueid: widget.leagueid, season: widget.season),
          FutureMatchPage(leagueid: widget.leagueid, season: widget.season),
          RecentMatchPage(leagueid: widget.leagueid, season: widget.season),
          StandingPage(leagueid: widget.leagueid, season: widget.season),
          TopScorePage(leagueid: widget.leagueid, season: widget.season),
        ]),
      ),
    );
  }
}

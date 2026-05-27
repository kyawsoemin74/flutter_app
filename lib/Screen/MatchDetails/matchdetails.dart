import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:football_xt_latest/constent.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Provider/Ads/ads.dart';
import '../../Provider/match.dart';
import 'Tab/headtohead.dart';
import 'Tab/lineup.dart';
import 'Tab/matchpreview.dart';
import 'Tab/odds.dart';
import 'Tab/table.dart';
import 'Tab/timeline.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;
import 'widgets/match_header.dart';
import 'widgets/venue_card.dart';
import 'widgets/tabbar.dart';

class DetailsPage extends StatefulWidget {
  final int matchId;
  const DetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with SingleTickerProviderStateMixin {
  static const int tabCount = 5;
  TabController? tabController;

  String get _firstTabLabel {
    final match = Provider.of<MatchProvider>(context, listen: false);
    final status = match.singleMatchData?.status;
    final currentStatus = status != null ? matchstatus(sort: status) : 'fix';
    return currentStatus == 'fix' ? 'Preview' : 'Facts';
  }

  bool get _isPreviewTab {
    final match = Provider.of<MatchProvider>(context, listen: false);
    return match.singleMatchData != null &&
        matchstatus(sort: match.singleMatchData!.status) == 'fix';
  }

  List<Tab> get tablist => [
        Tab(child: Text(_firstTabLabel.tr)),
        Tab(child: Text("Odds".tr)),
        Tab(child: Text("Lineup".tr)),
        Tab(child: Text("H2H".tr)),
        Tab(child: Text("Table".tr)),
      ];

  bool loading = true;

  Future loaddata() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    debugPrint('Loading details and events for: ${widget.matchId}');
    await Future.wait([
      matchProvider.fetchMatchDetails(widget.matchId),
      matchProvider.getsinglematchinfo(widget.matchId),
      matchProvider.getMatchEvents(matchid: widget.matchId),
      matchProvider.getMatchLineup(matchid: widget.matchId),
      matchProvider.geth2h(matchid: widget.matchId),
    ]);
    setState(() {
      loading = false;
    });
  }

  void _handleTabChange() {
    if (tabController?.indexIsChanging == true) return;
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    final currentIndex = tabController?.index ?? 0;

    switch (currentIndex) {
      case 0:
        if (matchProvider.singlematch.isEmpty) {
          matchProvider.getsinglematchinfo(widget.matchId);
        }
        break;
      case 1:
        if (matchProvider.odds.isEmpty) {
          matchProvider.getOdds(matchid: widget.matchId);
        }
        break;
      case 2:
        debugPrint('LINEUP TAB OPENED: matchId=${widget.matchId}');
        if (matchProvider.lineups.isEmpty) {
          matchProvider.getMatchLineup(matchid: widget.matchId);
        }
        break;
      case 3:
        if (matchProvider.h2h.isEmpty) {
          matchProvider.geth2h(matchid: widget.matchId);
        }
        break;
      case 4:
      default:
        break;
    }
  }

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  Widget currentAd = const SizedBox(
    height: 0,
    width: 0,
  );
  Future<void> _loadAd() async {
    final provider = Provider.of<Adsprovider?>(context, listen: false);
    final String? gBannerId = provider?.ads?.gBanner;
    if (gBannerId == null || gBannerId.isEmpty) return;

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: gBannerId,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          if (!mounted) return;
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
    final provider = Provider.of<Adsprovider?>(context, listen: false);
    final String? fbBannerId = provider?.ads?.fbBanner;
    if (fbBannerId == null || fbBannerId.isEmpty) return const SizedBox.shrink();

    return fb.BannerAd(
      placementId: fbBannerId,
      bannerSize: fb.BannerSize.STANDARD,
      listener: fb.BannerAdListener(
        onClicked: () {
          print("Banner Ad: click");
        },
        onError: (code, message) {
          print("Banner Ad: $code -->  $message");
        },
        onLoaded: () {
          if (!mounted) return;
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
    final provider = Provider.of<Adsprovider?>(context, listen: false);
    final bool hasFb = provider?.ads?.fb == 1;
    if (hasFb) {
      currentAd = _showfbBannerAd(context);
    } else {
      currentAd = const SizedBox(
        height: 0,
        width: 0,
      );
    }
    if (mounted) setState(() {});
  }

  Widget bannerads() {
    if (_anchoredAdaptiveAd == null) {
      return const SizedBox.shrink();
    }
    final size = _anchoredAdaptiveAd!.size;
    return Container(
      color: Colors.transparent,
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: AdWidget(ad: _anchoredAdaptiveAd!),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<Adsprovider?>(context, listen: false);
    if (provider != null && provider.ads != null && provider.ads!.google == 1) {
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
    super.initState();
    loadads();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loaddata();
    });
    tabController = TabController(length: tabCount, vsync: this)
      ..addListener(_handleTabChange);
  }

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchProvider>(context);
    final provider = Provider.of<Adsprovider?>(context);
    final bool hasFb = provider?.ads?.fb == 1;
    final bool hasGoogle = provider?.ads?.google == 1;
    return Scaffold(
      bottomNavigationBar: hasFb
          ? currentAd
          : hasGoogle
              ? _isLoaded
                  ? bannerads()
                  : const SizedBox()
              : const SizedBox(),
      appBar: AppBar(
        title: Text("Match Details".tr),
      ),

      body: loading || match.isLoadingMatchDetails || match.singleMatchData == null
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: MatchHeader(match: match),
                  ),
                  SliverPersistentHeader(
                      delegate: TabbarBox(
                          tabBar: TabBar(
                              tabs: tablist,
                              indicator: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(50.r)),
                              controller: tabController,
                              isScrollable: true))),
                ];
              },
              body: TabBarView(
                controller: tabController,
                children: [
                  _isPreviewTab
                      ? _buildPreviewTabWithVenue(match)
                      : FactsPage(teama: 0, teamb: 0),
                  OddsPage(matchId: widget.matchId),
                  const LineUpPage(),
                  const HeadToHeadPage(),
                  const TablePage(),
                ],
              )),


    );
  }
}

// Countdown moved to widgets/countdown.dart

// TabbarBox moved to widgets/tabbar.dart

  Widget _buildPreviewTabWithVenue(MatchProvider match) {
    final venueName = match.singleMatchData?.venueName;
    final venueCity = match.singleMatchData?.venueCity;
    final hasVenueData =
        (venueName?.isNotEmpty ?? false) || (venueCity?.isNotEmpty ?? false);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MAtchPreviewPage(),
          if (hasVenueData) ...[
            SizedBox(height: 24.h),
            VenueCard(venueName: venueName, venueCity: venueCity),
          ],
        ],
      ),
    );
  }

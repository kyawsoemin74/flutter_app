import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/constent.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../../Provider/Ads/ads.dart';
import '../../Provider/match.dart';
import 'Tab/headtohead.dart';
import 'Tab/lineup.dart';
import 'Tab/odds.dart';
import 'Tab/statis.dart';
import 'Tab/table.dart';
import 'Tab/timeline.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;

class DetailsPage extends StatefulWidget {
  final int matchId;
  const DetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List<Tab> tablist = [
    Tab(child: Text("Odds".tr)),
    Tab(child: Text("Facts".tr)),
    Tab(child: Text("Statis".tr)),
    Tab(child: Text("Lineup".tr)),
    Tab(child: Text("H2H".tr)),
    Tab(child: Text("Table".tr)),
  ];

  bool loading = true;

  Future loaddata() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    await Future.wait([
      matchProvider.fetchMatchDetails(widget.matchId),
      matchProvider.getsinglematchinfo(widget.matchId),
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
        if (matchProvider.odds.isEmpty) {
          matchProvider.getOdds(matchid: widget.matchId);
        }
        break;
      case 1:
      case 3:
        if (matchProvider.singlematch.isEmpty) {
          matchProvider.getsinglematchinfo(widget.matchId);
        }
        break;
      case 4:
        if (matchProvider.h2h.isEmpty) {
          matchProvider.geth2h(matchid: widget.matchId);
        }
        break;
      case 2:
      case 5:
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
    tabController = TabController(length: tablist.length, vsync: this)
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          height: 126.h,
                          width: 330.w,
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 80.h,
                                    width: 110.w,
                                    padding: EdgeInsets.all(15.r),
                                    decoration: const BoxDecoration(),
                                    child: match.singleMatchData!.homeLogo != null 
                                        ? Image.network(match.singleMatchData!.homeLogo!)
                                        : const Icon(Icons.sports_soccer, color: Colors.white),
                                  ),
                                  Container(
                                    width: 110.w,
                                    height: 46.h,
                                    alignment: Alignment.topCenter,
                                    decoration: const BoxDecoration(),
                                    child: Text(
                                      match.singleMatchData!.homeTeam ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12.sp),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (matchstatus(
                                          sort: match.singleMatchData!.status) !=
                                      "fix")
                                    Container(
                                      alignment: Alignment.center,
                                      height: 80.h,
                                      width: 110.w,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        match.singleMatchData!.score ?? "0 - 0",
                                        style: TextStyle(
                                            fontSize: 30.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singleMatchData!.status) ==
                                      "fix")
                                    Container(
                                      alignment: Alignment.center,
                                      height: 80.h,
                                      width: 110.w,
                                      decoration: const BoxDecoration(),
                                      child: SlideCountdown(
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.r)),
                                        duration: ftmatchdurationdata(match
                                            .singleMatchData!.matchTime),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singleMatchData!.status) ==
                                      "live")
                                    Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        match.singleMatchData!.status ?? "LIVE",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singleMatchData!.status) ==
                                      "rec")
                                    Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        match.singleMatchData!.status ?? "FT",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singleMatchData!.status) ==
                                      "fix")
                                    Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        match.singleMatchData!.matchTime ?? '',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    )
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                      height: 80.h,
                                      width: 110.w,
                                      padding: EdgeInsets.all(15.r),
                                      decoration: const BoxDecoration(),
                                      child: match.singleMatchData!.awayLogo != null
                                          ? Image.network(match.singleMatchData!.awayLogo!)
                                          : const Icon(Icons.sports_soccer, color: Colors.white),
                                  ),
                                  Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        match.singleMatchData!.awayTeam ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                  OddsPage(matchId: widget.matchId),
                  FactsPage(teama: 0, teamb: 0),
                  const StatisPage(),
                  const LineUpPage(),
                  const HeadToHeadPage(),
                  const TablePage(),
                ],
              )),
      // body: loading
      //     ? const Center(
      //         child: CupertinoActivityIndicator(
      //           color: Colors.white,
      //         ),
      //       )
      //     : NestedScrollView(
      //         headerSliverBuilder: (context, innerBoxIsScrolled) {
      //           return [
      //             SliverAppBar(
      //               leading: Row(
      //                 mainAxisAlignment: MainAxisAlignment.end,
      //                 children: [
      //                   InkWell(
      //                     onTap: () {
      //                       Navigator.pop(context);
      //                     },
      //                     child: Container(
      //                       padding: EdgeInsets.only(left: 5.w),
      //                       height: 40.h,
      //                       width: 40.w,
      //                       decoration: BoxDecoration(
      //                           color: const Color(0xFF2F2F39),
      //                           borderRadius: BorderRadius.circular(5.r)),
      //                       child: const Icon(Icons.arrow_back_ios),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               title: Column(
      //                 children: [
      //                   Text(
      //                     "Match Details",
      //                     style: TextStyle(
      //                         fontSize: 17.sp, fontWeight: FontWeight.w600),
      //                   ),
      //                   Text(
      //                     "${match.singlematch.first.league!.country} - ${match.singlematch.first.league!.name}",
      //                     style: TextStyle(
      //                         fontSize: 14.sp,
      //                         fontWeight: FontWeight.w500,
      //                         color: Colors.white.withOpacity(0.60)),
      //                   )
      //                 ],
      //               ),
      //               expandedHeight: 180.h,
      //               collapsedHeight: 180.h,
      //               flexibleSpace: Column(
      //                 mainAxisAlignment: MainAxisAlignment.end,
      //                 children: [
      //                   Container(
      //                     margin: EdgeInsets.only(bottom: 10.h),
      //                     height: 156.h,
      //                     width: 330.w,
      //                     child: Row(
      //                       children: [
      //                         InkWell(
      //                           onTap: () {},
      //                           child: Column(
      //                             children: [
      //                               Container(
      //                                 height: 80.h,
      //                                 width: 110.w,
      //                                 padding: EdgeInsets.all(15.r),
      //                                 decoration: const BoxDecoration(),
      //                                 child: CircleAvatar(
      //                                     radius: 15.r,
      //                                     backgroundImage: NetworkImage(match
      //                                         .singlematch
      //                                         .first
      //                                         .teams!
      //                                         .home['logo'])),
      //                               ),
      //                               Container(
      //                                 width: 110.w,
      //                                 height: 46.h,
      //                                 alignment: Alignment.topCenter,
      //                                 decoration: const BoxDecoration(),
      //                                 child: Text(
      //                                   match.singlematch.first.teams!
      //                                       .home['name'],
      //                                   style: TextStyle(
      //                                       color: Colors.white,
      //                                       fontSize: 12.sp),
      //                                 ),
      //                               )
      //                             ],
      //                           ),
      //                         ),
      //                         Column(
      //                           children: [
      //                             Container(
      //                               alignment: Alignment.center,
      //                               height: 80.h,
      //                               width: 110.w,
      //                               decoration: const BoxDecoration(),
      //                               child: Text(
      //                                 "${match.singlematch.first.goals!.home ?? 0}-${match.singlematch.first.goals!.home ?? 0}",
      //                                 style: TextStyle(
      //                                     fontSize: 30.sp,
      //                                     fontWeight: FontWeight.w700,
      //                                     color: Colors.white),
      //                               ),
      //                             ),
      //                             Container(
      //                               width: 110.w,
      //                               height: 46.h,
      //                               alignment: Alignment.topCenter,
      //                               decoration: const BoxDecoration(),
      //                               child: Text(
      //                                 "${match.singlematch.first.fixture!.status!.short!}-${match.singlematch.first.fixture!.status!.elapsed ?? 0}'",
      //                                 style: TextStyle(
      //                                     fontSize: 12.sp,
      //                                     fontWeight: FontWeight.w600,
      //                                     color: Colors.white),
      //                               ),
      //                             )
      //                           ],
      //                         ),
      //                         InkWell(
      //                           onTap: () {},
      //                           child: Column(
      //                             children: [
      //                               Container(
      //                                   height: 80.h,
      //                                   width: 110.w,
      //                                   padding: EdgeInsets.all(15.r),
      //                                   decoration: const BoxDecoration(),
      //                                   child: CircleAvatar(
      //                                       radius: 15.r,
      //                                       backgroundImage: NetworkImage(match
      //                                           .singlematch
      //                                           .first
      //                                           .teams!
      //                                           .away['logo']))),
      //                               Container(
      //                                   width: 110.w,
      //                                   height: 46.h,
      //                                   alignment: Alignment.topCenter,
      //                                   decoration: const BoxDecoration(),
      //                                   child: Text(
      //                                     match.singlematch.first.teams!
      //                                         .away['name'],
      //                                     style: TextStyle(
      //                                         color: Colors.white,
      //                                         fontSize: 12.sp),
      //                                   ))
      //                             ],
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               bottom: TabBar(
      //                 tabs: tablist,
      //                 indicatorSize: TabBarIndicatorSize.tab,
      //                 isScrollable: true,
      //                 indicatorPadding: EdgeInsets.symmetric(vertical: 5.h),
      //                 labelColor: Colors.white,
      //                 unselectedLabelColor: Colors.grey,
      //                 indicator: BoxDecoration(
      //                     color: color1,
      //                     borderRadius: BorderRadius.circular(65.r)),
      //                 controller: tabController,
      //               ),
      //             ),
      //
      // ];
      //         },
      //         body: TabBarView(
      //           controller: tabController,
      //           children: [
      //             const MatchSummaryPage(),
      //             TimeLinePage(teama: widget.team1, teamb: widget.team2),
      //             Container(),
      //             const HeadToHeadPage()
      //           ],
      //         ),
      //       ),
    );
  }
}

class TabbarBox extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const TabbarBox({required this.tabBar});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Container(
      child: tabBar,
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 50.h;

  @override
  // TODO: implement minExtent
  double get minExtent => 50.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

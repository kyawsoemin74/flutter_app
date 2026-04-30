// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/constent.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../../Ads_Code/ads_code.dart';
import '../../Provider/Ads/ads.dart';
import '../../Provider/match.dart';
import 'Tab/headtohead.dart';
import 'Tab/lineup.dart';
import 'Tab/matchpreview.dart';
import 'Tab/matchsummary.dart';
import 'Tab/timeline.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DetailsPage extends StatefulWidget {
  final int fictureid;
  final int team1;
  final int team2;
  const DetailsPage(
      {Key? key,
      required this.fictureid,
      required this.team1,
      required this.team2})
      : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List<Tab> tablist = [
    Tab(child: Text("Timeline".tr)),
    Tab(child: Text("Statistics".tr)),
    Tab(child: Text("Line Up".tr)),
    Tab(child: Text("Head to Head".tr)),
  ];

  bool loading = true;

  Future loaddata() async {
    final match = Provider.of<MatchProvider>(context, listen: false);
    try {
      await match.getsinglematchinfo(widget.fictureid);
      // await match.geth2h(teamid1: widget.team1, teamid2: widget.team2);
      // match.getslineup(widget.fictureid);
      // match.getstatis(widget.fictureid);
      // match.getplayerstatics(widget.fictureid);
      // match.getmatchevent(widget.fictureid);
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
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
    tabController = TabController(length: tablist.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchProvider>(context);
    final provider = Provider.of<Adsprovider>(context);
    return Scaffold(
      bottomNavigationBar: provider.ads!.fb == 1
          ? currentAd
          : provider.ads!.google == 1
              ? _isLoaded
                  ? bannerads()
                  : SizedBox()
              : SizedBox(),
      appBar: AppBar(
        title: Text("Match Details".tr),
      ),

      body: loading || match.singlematch.isEmpty
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
                                    child: match.singlematch.first.teams?.home['logo'] != null 
                                        ? Image.network(match.singlematch.first.teams!.home['logo'])
                                        : const Icon(Icons.sports_soccer, color: Colors.white),
                                  ),
                                  Container(
                                    width: 110.w,
                                    height: 46.h,
                                    alignment: Alignment.topCenter,
                                    decoration: const BoxDecoration(),
                                    child: Text(
                                      match.singlematch.first.teams!
                                          .home['name'],
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
                                          sort: match.singlematch.first.fixture!
                                              .status!.short) !=
                                      "fix")
                                    Container(
                                      alignment: Alignment.center,
                                      height: 80.h,
                                      width: 110.w,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        "${match.singlematch.first.goals!.home ?? 0}-${match.singlematch.first.goals!.away ?? 0}",
                                        style: TextStyle(
                                            fontSize: 30.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singlematch.first.fixture!
                                              .status!.short) ==
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
                                            .singlematch.first.fixture!.date!),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singlematch.first.fixture!
                                              .status!.short) ==
                                      "live")
                                    Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        "${match.singlematch.first.fixture!.status!.short!}-${match.singlematch.first.fixture!.status!.elapsed ?? 0}'",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singlematch.first.fixture!
                                              .status!.short) ==
                                      "rec")
                                    Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        "${match.singlematch.first.fixture!.status!.short!}-${match.singlematch.first.fixture!.status!.elapsed}",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  if (matchstatus(
                                          sort: match.singlematch.first.fixture!
                                              .status!.short) ==
                                      "fix")
                                    Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        DateFormat('dd MMM, hh:mm a').format(
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                match.singlematch.first.fixture!
                                                        .timestamp! *
                                                    1000000)),
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
                                      child: match.singlematch.first.teams?.away['logo'] != null
                                          ? Image.network(match.singlematch.first.teams!.away['logo'])
                                          : const Icon(Icons.sports_soccer, color: Colors.white),
                                  ),
                                  Container(
                                      width: 110.w,
                                      height: 46.h,
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(),
                                      child: Text(
                                        match.singlematch.first.teams!
                                            .away['name'],
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
                  TimeLinePage(teama: widget.team1, teamb: widget.team2),
                  const MatchSummaryPage(),
                  LineUpPage(),
                  const HeadToHeadPage(),
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

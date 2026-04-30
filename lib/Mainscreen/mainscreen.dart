// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/Screen/League/Allleague/allleague.dart';
import 'package:football_xt_latest/constent.dart';

import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import '../Screen/Drawer/drawer.dart';
import '../Screen/Homepage/home.dart';
import '../Screen/Match/matchs.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Provider/Ads/ads.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MAinScreenpage extends StatefulWidget {
  const MAinScreenpage({Key? key}) : super(key: key);

  @override
  State<MAinScreenpage> createState() => _MAinScreenpageState();
}

class _MAinScreenpageState extends State<MAinScreenpage> {
  final PageController _pageController = PageController();
  final InAppReview _inAppReview = InAppReview.instance;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  // ads end

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Adsprovider>(context);
    return Scaffold(
      key: _key,
      endDrawer: const DrawerPage(),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            provider.ads!.fb == 1
                ? currentAd
                : provider.ads!.google == 1
                    ? _isLoaded
                        ? bannerads()
                        : SizedBox()
                    : SizedBox(),
            Container( // Changed to use AppConfig.scaffoldBgColor
              color: AppConfig.scaffoldBgColor,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      _pageController.jumpToPage(0);
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.home,
                            color: Colors.white,
                          ),
                          Text(
                            "Home".tr,
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _pageController.jumpToPage(1);
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: Image.asset(
                                "images/football1.png",
                                color: Colors.white,
                              )),
                          Text(
                            "Match".tr,
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _pageController.jumpToPage(2);
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: Image.asset(
                              "images/podium.png",
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "League".tr,
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _key.currentState!.openEndDrawer();
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                          Text(
                            "Menu".tr,
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          const HomePage(),
          const Matchspage(),
          const AllleaguePage(),
        ],
      ),
    );
  }

  void redirectpage(Widget name) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => name,
        ));
  }
}

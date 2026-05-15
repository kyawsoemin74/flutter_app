// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/Screen/League/Allleague/allleague.dart';
import 'package:football_xt_latest/constent.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../Screen/Drawer/drawer.dart';
import '../Screen/Match/matchs.dart';
import '../Screen/News/news.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Provider/Ads/ads.dart';
import 'package:easy_audience_network/easy_audience_network.dart' as fb;

class MAinScreenpage extends StatefulWidget {
  const MAinScreenpage({super.key});

  @override
  State<MAinScreenpage> createState() => _MAinScreenpageState();
}

class _MAinScreenpageState extends State<MAinScreenpage> {
  int _selectedIndex = 0;

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
      debugPrint('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: provider.ads!.gBanner!,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('$ad loaded: ${ad.responseInfo}');
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Anchored adaptive banner failedToLoad: $error');
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
          debugPrint("Banner Ad: click");
        },
        onError: (code, message) {
          debugPrint("Banner Ad: $code -->  $message");
        },
        onLoaded: () {
          setState(() {
            _isLoaded = true;
          });
          debugPrint("Banner Ad: loaded");
        },
        onLoggingImpression: () {
          debugPrint("Banner Ad: impression");
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
    if (provider.isLoaded && provider.ads != null && provider.ads!.google == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAd();
      });
    }
  }

  @override
  void dispose() {
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Adsprovider>(context);
    // Ensure ads is loaded, otherwise show loading
    if (!provider.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      key: _key,
      endDrawer: const DrawerPage(),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            provider.ads?.fb == 1
                ? currentAd
                : provider.ads?.google == 1
                    ? _isLoaded
                        ? bannerads()
                        : SizedBox()
                    : SizedBox(),
            Container(
              color: AppConfig.scaffoldBgColor,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          color: _selectedIndex == 0 ? Colors.white : Colors.white70,
                          size: 24.sp,
                        ),
                        Text(
                          "Match".tr,
                          style: TextStyle(
                            color: _selectedIndex == 0 ? Colors.white : Colors.white70,
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.article,
                          color: _selectedIndex == 1 ? Colors.white : Colors.white70,
                          size: 24.sp,
                        ),
                        Text(
                          "News".tr,
                          style: TextStyle(
                            color: _selectedIndex == 1 ? Colors.white : Colors.white70,
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.leaderboard,
                          color: _selectedIndex == 2 ? Colors.white : Colors.white70,
                          size: 24.sp,
                        ),
                        Text(
                          "League".tr,
                          style: TextStyle(
                            color: _selectedIndex == 2 ? Colors.white : Colors.white70,
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                      _key.currentState!.openEndDrawer();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.menu,
                          color: _selectedIndex == 3 ? Colors.white : Colors.white70,
                          size: 24.sp,
                        ),
                        Text(
                          "Menu".tr,
                          style: TextStyle(
                            color: _selectedIndex == 3 ? Colors.white : Colors.white70,
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Matchspage(),
          const NewsPage(),
          const AllleaguePage(),
          Container(
            color: AppConfig.scaffoldBgColor,
            child: Center(
              child: Text(
                'Menu'.tr,
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
              ),
            ),
          ),
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

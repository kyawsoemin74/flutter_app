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
import '../model/Ads/ads.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;

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
  bool _hasInitializedAdLoad = false;
  bool _isDisposed = false;

  Widget currentAd = const SizedBox.shrink();

  Future<void> _loadAd() async {
    if (!mounted || _isDisposed) return;
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final bannerId = provider.ads?.gBanner;
    if (bannerId == null || bannerId.isEmpty) return;

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('$ad loaded: ${ad.responseInfo}');
          if (!mounted || _isDisposed) return;
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
    await _anchoredAdaptiveAd?.load();
  }

  Widget _showfbBannerAd(BuildContext context) {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final fbBannerId = provider.ads?.fbBanner;
    if (fbBannerId == null || fbBannerId.isEmpty) {
      return const SizedBox.shrink();
    }

    return fb.BannerAd(
      placementId: fbBannerId,
      bannerSize: fb.BannerSize.STANDARD,
      listener: fb.BannerAdListener(
        onClicked: () {
          debugPrint('Banner Ad: click');
        },
        onError: (code, message) {
          debugPrint('Banner Ad: $code -->  $message');
        },
        onLoaded: () {
          if (!mounted || _isDisposed) return;
          setState(() {
            _isLoaded = true;
          });
          debugPrint('Banner Ad: loaded');
        },
        onLoggingImpression: () {
          debugPrint('Banner Ad: impression');
        },
      ),
    );
  }

  // facebook ads end

  Future<void> _prepareFbBanner() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    if (provider.ads?.fb == 1) {
      currentAd = _showfbBannerAd(context);
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    }
  }

  Widget bannerads() {
    if (_anchoredAdaptiveAd == null) {
      return const SizedBox.shrink();
    }
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
  }

  @override
  void dispose() {
    _isDisposed = true;
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.select<Adsprovider, Ads?>((provider) => provider.ads);
    final isLoaded = context.select<Adsprovider, bool>((provider) => provider.isLoaded);

    if (isLoaded && ads != null && !_hasInitializedAdLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_hasInitializedAdLoad || _isDisposed) return;
        if (ads.google == 1) {
          _loadAd();
        }
        if (ads.fb == 1) {
          _prepareFbBanner();
        }
      });
      _hasInitializedAdLoad = true;
    }

    final bool hasFbAd = ads?.fb == 1;
    final bool hasGoogleAd = ads?.google == 1;
    final Widget adWidget = hasFbAd
        ? currentAd
        : hasGoogleAd
            ? _isLoaded
                ? bannerads()
                : const SizedBox(height: 60)
            : const SizedBox.shrink();

    return Scaffold(
      key: _key,
      endDrawer: const DrawerPage(),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            adWidget,
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

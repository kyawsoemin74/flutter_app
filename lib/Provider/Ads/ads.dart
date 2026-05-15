// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../Httpservice/ads.dart';
import '../../model/Ads/ads.dart';

class Adsprovider extends ChangeNotifier {
  Ads? ads;
  bool isLoaded = false;
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  final AdsService _adsService = AdsService();

  Future<void> loadAds() async {
    try {
      ads = await _adsService.fetchAds();
      isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load ads: $e');
      isLoaded = false;
      notifyListeners();
    }
  }

  Future openads() async {
    if (!isLoaded || ads == null) return;

    AppOpenAd.load(
      adUnitId: ads!.gopenAds!,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('$ad loaded');
          _appOpenAd = ad;
          _appOpenAd!.show();
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
      request: const AdRequest(),
    );
  }

  // bool get isAdAvailable {
  //   return _appOpenAd != null;
  // }
}

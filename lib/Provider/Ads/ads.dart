// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../Httpservice/ads.dart';
import '../../model/Ads/ads.dart';


class Adsprovider extends ChangeNotifier {
  Ads? ads;
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  Future getads(BuildContext context) async {
    ads = await HttpAds().getads();
    notifyListeners();
  }

  Future openads() async {
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
          // Handle the error.
        },
      ),
      request: const AdRequest(),
    );
  }

  // bool get isAdAvailable {
  //   return _appOpenAd != null;
  // }
}

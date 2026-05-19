import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  /// Loads an anchored adaptive banner for the current orientation.
  static Future<BannerAd?> loadAdaptiveBanner(String adUnitId, BuildContext context) async {
    if (adUnitId.isEmpty) return null;
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());
    if (size == null) return null;
    final completer = Completer<BannerAd>();
    final banner = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          completer.completeError(error);
        },
      ),
    );
    await banner.load();
    try {
      return await completer.future;
    } catch (_) {
      return null;
    }
  }

  static Widget bannerWidget(BannerAd ad) {
    final size = ad.size;
    return Container(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      color: Colors.transparent,
      child: AdWidget(ad: ad),
    );
  }
}

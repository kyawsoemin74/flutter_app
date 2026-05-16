// Stubbed easy_audience_network API — temporary safe fallback for release builds.
// This file provides minimal types and methods used across the app so the
// project can compile with ads disabled. Restore or remove when enabling real ads.

import 'dart:async';
import 'package:flutter/widgets.dart';

class EasyAudienceNetwork {
  /// Initialize stubbed SDK (no-op)
  static Future<void> init({
    bool testing = false,
    bool testMode = false,
    bool iOSAdvertiserTrackingEnabled = false,
  }) async {}
}

class BannerSize {
  static const STANDARD = 1;
}

/// A widget stub that replaces the real FB banner widget.
class BannerAd extends StatelessWidget {
  final String? placementId;
  final dynamic listener;
  final dynamic bannerSize;

  const BannerAd({Key? key, this.placementId, this.listener, this.bannerSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Render nothing when ads are disabled
    return const SizedBox.shrink();
  }
}

class BannerAdListener {
  BannerAdListener({this.onClicked, this.onError, this.onLoaded, this.onLoggingImpression});
  final void Function()? onClicked;
  final void Function(dynamic code, dynamic message)? onError;
  final void Function()? onLoaded;
  final void Function()? onLoggingImpression;
}

class InterstitialAd {
  final String? placementId;
  dynamic listener;

  InterstitialAd(this.placementId);
  Future<void> load() async {}
  void show() {}
  void destroy() {}
  void dispose() {}
}

class InterstitialAdListener {
  InterstitialAdListener({this.onLoaded, this.onError, this.onDismissed});
  final void Function()? onLoaded;
  final void Function(dynamic code, dynamic message)? onError;
  final void Function()? onDismissed;
}

// Minimal alias used by code expecting an AdWidget type
typedef AdWidget = Widget;

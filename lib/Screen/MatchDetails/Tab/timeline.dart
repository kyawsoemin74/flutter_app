import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../../Ads_Code/ads_code.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import '../../../model/MatchEvent/matchevent.dart';
import '../../Matchdetails/Tab/matchpreview.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;
import '../widgets/venue_card.dart';


class FactsPage extends StatefulWidget {
  final int teama;
  final int teamb;
  const FactsPage({Key? key, required this.teama, required this.teamb})
      : super(key: key);

  @override
  State<FactsPage> createState() => _FactsPageState();
}

class _FactsPageState extends State<FactsPage> {
  List<String> imagelist = [
    "Assets/Icon/image 20.png",
    "Assets/Icon/image 20.png",
    "Assets/Icon/image 20.png",
    "Assets/Icon/image 20.png"
  ];

 InterstitialAd? _interstitialAd;
  fb.InterstitialAd? _fbinterstitialAd;
  int _numInterstitialLoadAttempts = 0;
  Future _createInterstitialAd() async {
     final provider = Provider.of<Adsprovider>(context, listen: false);
    InterstitialAd.load(
      adUnitId: provider.ads!.gInterstitial!,
      request: const AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (kDebugMode) {
            print('$ad loaded');
          }
          ad.show();
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;

          _createInterstitialAd();
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('Warning: attempt to show interstitial before loaded.');
      }
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('ad onAdShowedFullScreenContent.');
        }
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('$ad onAdDismissedFullScreenContent.');
        }
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  bool _fbisInterstitialAdLoaded = false;
  Future loadfbInterstitialAd() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final interstitialAd = fb.InterstitialAd(provider.ads!.fbInterstitial!);
    interstitialAd.listener = fb.InterstitialAdListener(
      onLoaded: () {
        print('interstitial ad loaded');
        _fbisInterstitialAdLoaded = true;
      },
      onError: (code, message) {
        print('interstitial ad error\ncode = $code\nmessage = $message');
      },
      onDismissed: () {
        interstitialAd.destroy();
        loadfbInterstitialAd();
      },
    );
    interstitialAd.load();
    _fbinterstitialAd = interstitialAd;
  }

  showfbInterstitialAd() {
    if (_fbisInterstitialAdLoaded == true) {
      _fbinterstitialAd!.show();
    } else if (kDebugMode) {
      print("Interstial Ad not yet loaded!");
    }
  }

  bool clickads() {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final box = Hive.isBoxOpen('ads') ? Hive.box('ads') : null;
    final clickads = box?.get('click') ?? 0;
    if (clickads % provider.ads!.adsClick! == 0) {
      if (kDebugMode) {
        print(true);
      }
      box?.put('click', clickads + 1);
      return true;
    } else {
      if (kDebugMode) {
        print(false);
      }
      box?.put('click', clickads + 1);
      return false;
    }
  }

  Future loadinterstitialads() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    if (provider.ads!.google == 1 && clickads() == true) {
      _createInterstitialAd();
    } else if (provider.ads!.fb == 1 && clickads() == true) {
      loadfbInterstitialAd().then((value) =>
          Future.delayed(Duration(seconds: 5), () => showfbInterstitialAd()));
    }
  }
  @override
  void initState() {loadinterstitialads();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchProvider>(context);
    final venueName = match.singleMatchData?.venueName;
    final venueCity = match.singleMatchData?.venueCity;
    final hasVenueData =
        (venueName?.isNotEmpty ?? false) || (venueCity?.isNotEmpty ?? false);
    final homeName = match.singleMatchData?.homeTeam?.trim().toLowerCase();
    final awayName = match.singleMatchData?.awayTeam?.trim().toLowerCase();

    debugPrint('Facts events length: ${match.events.length}');
    final bool hasNoEvents = match.events.isEmpty;
    final events = match.events;
    if (!hasNoEvents) {
      events.sort((a, b) => b.time!.elapsed!.compareTo(a.time!.elapsed!));
    }

    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasNoEvents) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    "No data Found".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final previous = index > 0 ? events[index - 1] : null;
                    final widgets = <Widget>[];
                    if (previous != null &&
                        (previous.time?.elapsed ?? 0) < 45 &&
                        (event.time?.elapsed ?? 0) >= 45) {
                      widgets.add(buildPeriodMarker('HT'));
                    }
                    widgets.add(buildTimelineItem(event, homeName, awayName));
                    if (index == events.length - 1 &&
                        (event.time?.elapsed ?? 0) >= 90) {
                      widgets.add(buildPeriodMarker('FT'));
                    }
                    return Column(children: widgets);
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 8.h);
                  },
                  itemCount: events.length,
                ),
              ),
            ],
            if (hasVenueData) ...[
              SizedBox(height: 24.h),
              VenueCard(venueName: venueName, venueCity: venueCity),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildPeriodMarker(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.white24, thickness: 1),
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Divider(color: Colors.white24, thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget buildTimelineItem(Matchevent event, String? homeName, String? awayName) {
    final eventTeamName = event.team?.name?.trim().toLowerCase();
    final isHome = event.team?.id == widget.teama || eventTeamName == homeName;
    final sideContent = buildEventCard(event, isHome);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: isHome
                ? Align(alignment: Alignment.centerRight, child: sideContent)
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 1.w, height: 10.h, color: Colors.white24),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Color(0xFF242424)),
                  ),
                  child: Text(
                    '${event.time?.elapsed ?? 0}\'',
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(width: 1.w, height: 10.h, color: Colors.white24),
              ],
            ),
          ),
          Expanded(
            child: !isHome
                ? Align(alignment: Alignment.centerLeft, child: sideContent)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildEventCard(Matchevent event, bool isHome) {
    final type = event.type?.toLowerCase() ?? '';
    final label = _eventEmoji(type, event.detail);
    final title = event.player?.name ?? '';
    final assist = event.assist?.name;
    final detail = event.detail ?? '';
    final scoreText = type == 'goal' && detail.isNotEmpty ? ' ($detail)' : '';
    final cardAlignment = isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = isHome ? TextAlign.right : TextAlign.left;

    Widget content;
    if (type == 'goal') {
      content = Column(
        crossAxisAlignment: cardAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  '$title$scoreText',
                  textAlign: textAlign,
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (assist != null && assist.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              'Assist: $assist',
              textAlign: textAlign,
              style: TextStyle(color: Colors.white60, fontSize: 10.sp),
            ),
          ],
        ],
      );
    } else if (type == 'card') {
      content = Column(
        crossAxisAlignment: cardAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (detail.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              detail,
              textAlign: textAlign,
              style: TextStyle(color: Colors.white60, fontSize: 10.sp),
            ),
          ],
        ],
      );
    } else if (type == 'subst' || type == 'substitution') {
      content = Column(
        crossAxisAlignment: cardAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Text(
                'Substitution',
                textAlign: textAlign,
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          _buildSubstitutionRow('IN', title, Colors.green),
          SizedBox(height: 4.h),
          _buildSubstitutionRow('OUT', assist ?? '', Colors.red),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: cardAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ${title.isNotEmpty ? title : event.team?.name ?? ''}',
            textAlign: textAlign,
            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
          if (detail.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              detail,
              textAlign: textAlign,
              style: TextStyle(color: Colors.white60, fontSize: 10.sp),
            ),
          ],
        ],
      );
    }

    return Container(
      width: 150.w,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Color(0xFF242424)),
      ),
      child: content,
    );
  }

  Widget _buildSubstitutionRow(String title, String name, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          '$title: ',
          style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 11.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _eventEmoji(String type, String? detail) {
    if (type == 'goal') return '⚽';
    if (type == 'card') {
      if (detail?.toLowerCase().contains('yellow') ?? false) return '🟨';
      if (detail?.toLowerCase().contains('red') ?? false) return '🟥';
      return '🟨';
    }
    if (type == 'subst' || type == 'substitution') return '🔁';
    return '•';
  }
}

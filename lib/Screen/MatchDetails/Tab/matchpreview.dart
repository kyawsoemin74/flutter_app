import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MAtchPreviewPage extends StatefulWidget {
  const MAtchPreviewPage({super.key});

  @override
  State<MAtchPreviewPage> createState() => _MAtchPreviewPageState();
}

class _MAtchPreviewPageState extends State<MAtchPreviewPage> {
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
  void initState() {
    loadinterstitialads();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchProvider>(context);
    return match.singlematch.first.fixture!.venue!.id == null
        ? Container()
        : Column(
            children: [
              Card(
                color: Colors.white.withOpacity(0.1),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                              height: 20.h,
                              width: 20.w,
                              child: Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              )),
                          SizedBox(width: 10.w),
                          Text(match.singlematch.first.fixture!.date?.toIso8601String() ?? ''),
                        ],
                      ),
                      SizedBox(height: 10.w),
                      Row(
                        children: [
                          Container(
                            height: 20.h,
                            width: 20.w,
                            child: Image.network(
                              match.singlematch.first.league!.logo!,
                              height: 20.h,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                              "${match.singlematch.first.league!.name} - ${match.singlematch.first.league!.round}")
                        ],
                      ),
                      SizedBox(height: 10.w),
                      Row(
                        children: [
                          Container(
                            height: 20.h,
                            width: 20.w,
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(match.singlematch.first.fixture!.venue!.city ??
                              ""),
                        ],
                      ),
                      SizedBox(height: 10.w),
                      Row(
                        children: [
                          Container(
                            height: 20.h,
                            width: 20.w,
                            child: SvgPicture.network(
                                match.singlematch.first.league!.flag ?? ""),
                          ),
                          SizedBox(width: 10.w),
                          Text(match.singlematch.first.league!.country!),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );

    // : FutureBuilder(
    //     future: httpVenues()
    //         .getvenues(venuid: match.singlematch.first.fixture!.venue!.id!),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         var data = snapshot.data[0];
    //         return Column(
    //           children: [
    //             Card(
    //               color: Colors.white.withOpacity(0.1),
    //               child: Container(
    //                 padding: EdgeInsets.all(10.r),
    //                 child: Column(
    //                   children: [
    //                     Row(
    //                       children: [
    //                         Container(
    //                             height: 20.h,
    //                             width: 20.w,
    //                             child: Icon(
    //                               Icons.calendar_month,
    //                               color: Colors.white,
    //                             )),
    //                         SizedBox(width: 10.w),
    //                         Text(DateFormat('MMM, EEE dd, hh:mm a').format(
    //                             DateTime.fromMicrosecondsSinceEpoch(match
    //                                     .singlematch
    //                                     .first
    //                                     .fixture!
    //                                     .timestamp! *
    //                                 1000000)))
    //                       ],
    //                     ),
    //                     SizedBox(height: 10.w),
    //                     Row(
    //                       children: [
    //                         Container(
    //                           height: 20.h,
    //                           width: 20.w,
    //                           child: Image.network(
    //                             match.singlematch.first.league!.logo!,
    //                             height: 20.h,
    //                           ),
    //                         ),
    //                         SizedBox(width: 10.w),
    //                         Text(
    //                             "${match.singlematch.first.league!.name} - ${match.singlematch.first.league!.round}")
    //                       ],
    //                     ),
    //                     SizedBox(height: 10.w),
    //                     Row(
    //                       children: [
    //                         Container(
    //                           height: 20.h,
    //                           width: 20.w,
    //                           child: Icon(
    //                             Icons.location_pin,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                         SizedBox(width: 10.w),
    //                         Text(data['address'] ?? ""),
    //                       ],
    //                     ),
    //                     SizedBox(height: 10.w),
    //                     Row(
    //                       children: [
    //                         Container(
    //                           height: 20.h,
    //                           width: 20.w,
    //                           child: Image.network(data['image']),
    //                         ),
    //                         SizedBox(width: 10.w),
    //                         Text(data['country']),
    //                       ],
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         );

    //         // return ListView.builder(
    //         //   itemCount: snapshot.data.length,
    //         //   itemBuilder: (context, index) {
    //         //     var data = snapshot.data[index];
    //         //     return ListTile(
    //         //       leading:
    //         //           CircleAvatar(backgroundImage: NetworkImage(data['image'])),
    //         //       title: Text(data['name']),
    //         //       isThreeLine: true,
    //         //       subtitle: Column(
    //         //         crossAxisAlignment: CrossAxisAlignment.start,
    //         //         children: [
    //         //           Text(
    //         //             "Address: ${data['address']}",
    //         //             style: TextStyle(color: Colors.white),
    //         //           ),
    //         //           Text(
    //         //             "city: ${data['city']}",
    //         //             style: TextStyle(color: Colors.white),
    //         //           )
    //         //         ],
    //         //       ),
    //         //     );
    //         //   },
    //         // );
    //       } else {
    //         return Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       }
    //     },
    //   );
  }
}

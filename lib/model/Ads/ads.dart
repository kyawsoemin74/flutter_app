// To parse this JSON data, do
//
//     final ads = adsFromJson(jsonString);

import 'dart:convert';

Ads adsFromJson(String str) => Ads.fromJson(json.decode(str));

String adsToJson(Ads data) => json.encode(data.toJson());

class Ads {
    int? google;
    int? fb;
    int? adsClick;
    String? onesignalappid;
    String? gopenAds;
    String? gBanner;
    String? gInterstitial;
    String? gvideoads;
    String? fbBanner;
    String? fbInterstitial;
    String? fBvideoads;

    Ads({
        this.google,
        this.fb,
        this.adsClick,
        this.onesignalappid,
        this.gopenAds,
        this.gBanner,
        this.gInterstitial,
        this.gvideoads,
        this.fbBanner,
        this.fbInterstitial,
        this.fBvideoads,
    });

    factory Ads.fromJson(Map<String, dynamic> json) => Ads(
        google: json["google"],
        fb: json["fb"],
        adsClick: json["ads_click"],
        onesignalappid: json["onesignalappid"],
        gopenAds: json["GopenAds"],
        gBanner: json["GBanner"],
        gInterstitial: json["GInterstitial"],
        gvideoads: json["Gvideoads"],
        fbBanner: json["FBBanner"],
        fbInterstitial: json["FBInterstitial"],
        fBvideoads: json["FBvideoads"],
    );

    Map<String, dynamic> toJson() => {
        "google": google,
        "fb": fb,
        "ads_click": adsClick,
        "onesignalappid": onesignalappid,
        "GopenAds": gopenAds,
        "GBanner": gBanner,
        "GInterstitial": gInterstitial,
        "Gvideoads": gvideoads,
        "FBBanner": fbBanner,
        "FBInterstitial": fbInterstitial,
        "FBvideoads": fBvideoads,
    };
}

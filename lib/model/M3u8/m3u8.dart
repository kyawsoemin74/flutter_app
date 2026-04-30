// To parse this JSON data, do
//
//     final m3U8 = m3U8FromJson(jsonString);

import 'dart:convert';

M3U8 m3U8FromJson(String str) => M3U8.fromJson(json.decode(str));

String m3U8ToJson(M3U8 data) => json.encode(data.toJson());

class M3U8 {
    M3U8({
        this.liveEnable,
        this.live,
    });

    int? liveEnable;
    List<Live>? live;

    factory M3U8.fromJson(Map<String, dynamic> json) => M3U8(
        liveEnable: json["live_enable"],
        live: List<Live>.from(json["Live"].map((x) => Live.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "live_enable": liveEnable,
        "Live": List<dynamic>.from(live!.map((x) => x.toJson())),
    };
}

class Live {
    Live({
        this.matchid,
        this.m3U8,
    });

    int? matchid;
    List<String>? m3U8;

    factory Live.fromJson(Map<String, dynamic> json) => Live(
        matchid: json["matchid"],
        m3U8: List<String>.from(json["m3u8"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "matchid": matchid,
        "m3u8": List<dynamic>.from(m3U8!.map((x) => x)),
    };
}

// To parse this JSON data, do
//
//     final liveStream2 = liveStream2FromJson(jsonString);

import 'dart:convert';

List<LiveStream2> liveStream2FromJson(String str) => List<LiveStream2>.from(json.decode(str).map((x) => LiveStream2.fromJson(x)));

String liveStream2ToJson(List<LiveStream2> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LiveStream2 {
    int? id;
    String? title;
    String? imagea;
    String? imageb;
    String? teama;
    String? teamb;
    String? m3U8;
    DateTime? createdAt;
    DateTime? updatedAt;

    LiveStream2({
        this.id,
        this.title,
        this.imagea,
        this.imageb,
        this.teama,
        this.teamb,
        this.m3U8,
        this.createdAt,
        this.updatedAt,
    });

    factory LiveStream2.fromJson(Map<String, dynamic> json) => LiveStream2(
        id: json["id"],
        title: json["title"],
        imagea: json["imagea"],
        imageb: json["imageb"],
        teama: json["teama"],
        teamb: json["teamb"],
        m3U8: json["m3u8"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "imagea": imagea,
        "imageb": imageb,
        "teama": teama,
        "teamb": teamb,
        "m3u8": m3U8,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

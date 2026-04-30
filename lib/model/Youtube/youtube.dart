// To parse this JSON data, do
//
//     final youtubedata = youtubedataFromJson(jsonString);

import 'dart:convert';

List<Youtubedata> youtubedataFromJson(String str) => List<Youtubedata>.from(json.decode(str).map((x) => Youtubedata.fromJson(x)));

String youtubedataToJson(List<Youtubedata> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Youtubedata {
    int? id;
    String? youtubeid;
    String? title;

    Youtubedata({
        this.id,
        this.youtubeid,
        this.title,
    });

    factory Youtubedata.fromJson(Map<String, dynamic> json) => Youtubedata(
        id: json["id"],
        youtubeid: json["youtubeid"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "youtubeid": youtubeid,
        "title": title,
    };
}

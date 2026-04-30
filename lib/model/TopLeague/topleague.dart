// To parse this JSON data, do
//
//     final topLeague = topLeagueFromJson(jsonString);

import 'dart:convert';

List<TopLeague> topLeagueFromJson(String str) => List<TopLeague>.from(json.decode(str).map((x) => TopLeague.fromJson(x)));

String topLeagueToJson(List<TopLeague> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TopLeague {
  String? image;
  int? id;
  int? season;
  String? name;

  TopLeague({
    this.image,
    this.id,
    this.season,
    this.name,
  });

  factory TopLeague.fromJson(Map<String, dynamic> json) => TopLeague(
    image: json["image"],
    id: json["id"],
    season: json["season"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "id": id,
    "season": season,
    "name": name,
  };
}

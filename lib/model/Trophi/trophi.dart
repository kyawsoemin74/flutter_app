// To parse this JSON data, do
//
//     final trophi = trophiFromJson(jsonString);

import 'dart:convert';

List<Trophi> trophiFromJson(String str) => List<Trophi>.from(json.decode(str).map((x) => Trophi.fromJson(x)));

String trophiToJson(List<Trophi> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Trophi {
    Trophi({
        this.league,
        this.country,
        this.season,
        this.place,
    });

    String? league;
    String? country;
    String? season;
    String? place;

    factory Trophi.fromJson(Map<String, dynamic> json) => Trophi(
        league: json["league"],
        country: json["country"],
        season: json["season"],
        place: json["place"],
    );

    Map<String, dynamic> toJson() => {
        "league": league,
        "country": country,
        "season": season,
        "place": place,
    };
}

// To parse this JSON data, do
//
//     final staticleague = staticleagueFromJson(jsonString);

import 'dart:convert';

Staticleague staticleagueFromJson(String str) => Staticleague.fromJson(json.decode(str));

String staticleagueToJson(Staticleague data) => json.encode(data.toJson());

class Staticleague {
    Staticleague({
        this.leagueenable,
        this.league,
    });

    int? leagueenable;
    List<LeagueElement>? league;

    factory Staticleague.fromJson(Map<String, dynamic> json) => Staticleague(
        leagueenable: json["leagueenable"],
        league: List<LeagueElement>.from(json["league"].map((x) => LeagueElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "leagueenable": leagueenable,
        "league": List<dynamic>.from(league!.map((x) => x.toJson())),
    };
}

class LeagueElement {
    LeagueElement({
        this.league,
        this.country,
        this.seasons,
    });

    LeagueLeague? league;
    Country? country;
    List<Season>? seasons;

    factory LeagueElement.fromJson(Map<String, dynamic> json) => LeagueElement(
        league: LeagueLeague.fromJson(json["league"]),
        country: Country.fromJson(json["country"]),
        seasons: List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "league": league!.toJson(),
        "country": country!.toJson(),
        "seasons": List<dynamic>.from(seasons!.map((x) => x.toJson())),
    };
}

class Country {
    Country({
        this.name,
        this.code,
        this.flag,
    });

    String? name;
    String? code;
    String? flag;

    factory Country.fromJson(Map<String, dynamic> json) => Country(
        name: json["name"],
        code: json["code"] == null ? null : json["code"],
        flag: json["flag"] == null ? null : json["flag"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "code": code == null ? null : code,
        "flag": flag == null ? null : flag,
    };
}

class LeagueLeague {
    LeagueLeague({
        this.id,
        this.name,
        this.type,
        this.logo,
    });

    int? id;
    String? name;
    String? type;
    String? logo;

    factory LeagueLeague.fromJson(Map<String, dynamic> json) => LeagueLeague(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        logo: json["logo"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "logo": logo,
    };
}

class Season {
    Season({
        this.year,
        this.start,
        this.end,
    });

    int? year;
    DateTime? start;
    DateTime? end;

    factory Season.fromJson(Map<String, dynamic> json) => Season(
        year: json["year"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
    );

    Map<String, dynamic> toJson() => {
        "year": year,
        "start": "${start!.year.toString().padLeft(4, '0')}-${start!.month.toString().padLeft(2, '0')}-${start!.day.toString().padLeft(2, '0')}",
        "end": "${end!.year.toString().padLeft(4, '0')}-${end!.month.toString().padLeft(2, '0')}-${end!.day.toString().padLeft(2, '0')}",
    };
}

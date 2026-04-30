// To parse this JSON data, do
//
//     final odd = oddFromJson(jsonString);

import 'dart:convert';

List<Odd> oddFromJson(String str) => List<Odd>.from(json.decode(str).map((x) => Odd.fromJson(x)));

String oddToJson(List<Odd> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Odd {
    Odd({
        this.fixture,
        this.league,
        this.teams,
        this.status,
        this.update,
        this.odds,
    });

    Fixture? fixture;
    League? league;
    Teams? teams;
    OddStatus? status;
    DateTime? update;
    List<OddElement>? odds;

    factory Odd.fromJson(Map<String, dynamic> json) => Odd(
        fixture: json["fixture"] == null ? null : Fixture.fromJson(json["fixture"]),
        league: json["league"] == null ? null : League.fromJson(json["league"]),
        teams: json["teams"] == null ? null : Teams.fromJson(json["teams"]),
        status: json["status"] == null ? null : OddStatus.fromJson(json["status"]),
        update: json["update"] == null ? null : DateTime.parse(json["update"]),
        odds: json["odds"] == null ? [] : List<OddElement>.from(json["odds"]!.map((x) => OddElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "fixture": fixture?.toJson(),
        "league": league?.toJson(),
        "teams": teams?.toJson(),
        "status": status?.toJson(),
        "update": update?.toIso8601String(),
        "odds": odds == null ? [] : List<dynamic>.from(odds!.map((x) => x.toJson())),
    };
}

class Fixture {
    Fixture({
        this.id,
        this.status,
    });

    int? id;
    FixtureStatus? status;

    factory Fixture.fromJson(Map<String, dynamic> json) => Fixture(
        id: json["id"],
        status: json["status"] == null ? null : FixtureStatus.fromJson(json["status"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status?.toJson(),
    };
}

class FixtureStatus {
    FixtureStatus({
        this.long,
        this.elapsed,
        this.seconds,
    });

    String? long;
    int? elapsed;
    String? seconds;

    factory FixtureStatus.fromJson(Map<String, dynamic> json) => FixtureStatus(
        long: json["long"],
        elapsed: json["elapsed"],
        seconds: json["seconds"],
    );

    Map<String, dynamic> toJson() => {
        "long": long,
        "elapsed": elapsed,
        "seconds": seconds,
    };
}

class League {
    League({
        this.id,
        this.season,
    });

    int? id;
    int? season;

    factory League.fromJson(Map<String, dynamic> json) => League(
        id: json["id"],
        season: json["season"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "season": season,
    };
}

class OddElement {
    OddElement({
        this.id,
        this.name,
        this.values,
    });

    int? id;
    String? name;
    List<Value>? values;

    factory OddElement.fromJson(Map<String, dynamic> json) => OddElement(
        id: json["id"],
        name: json["name"],
        values: json["values"] == null ? [] : List<Value>.from(json["values"]!.map((x) => Value.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "values": values == null ? [] : List<dynamic>.from(values!.map((x) => x.toJson())),
    };
}

class Value {
    Value({
        this.value,
        this.odd,
        this.handicap,
        this.main,
        this.suspended,
    });

    String? value;
    String? odd;
    String? handicap;
    bool? main;
    bool? suspended;

    factory Value.fromJson(Map<String, dynamic> json) => Value(
        value: json["value"],
        odd: json["odd"],
        handicap: json["handicap"],
        main: json["main"],
        suspended: json["suspended"],
    );

    Map<String, dynamic> toJson() => {
        "value": value,
        "odd": odd,
        "handicap": handicap,
        "main": main,
        "suspended": suspended,
    };
}

class OddStatus {
    OddStatus({
        this.stopped,
        this.blocked,
        this.finished,
    });

    bool? stopped;
    bool? blocked;
    bool? finished;

    factory OddStatus.fromJson(Map<String, dynamic> json) => OddStatus(
        stopped: json["stopped"],
        blocked: json["blocked"],
        finished: json["finished"],
    );

    Map<String, dynamic> toJson() => {
        "stopped": stopped,
        "blocked": blocked,
        "finished": finished,
    };
}

class Teams {
    Teams({
        this.home,
        this.away,
    });

    Away? home;
    Away? away;

    factory Teams.fromJson(Map<String, dynamic> json) => Teams(
        home: json["home"] == null ? null : Away.fromJson(json["home"]),
        away: json["away"] == null ? null : Away.fromJson(json["away"]),
    );

    Map<String, dynamic> toJson() => {
        "home": home?.toJson(),
        "away": away?.toJson(),
    };
}

class Away {
    Away({
        this.id,
        this.goals,
    });

    int? id;
    int? goals;

    factory Away.fromJson(Map<String, dynamic> json) => Away(
        id: json["id"],
        goals: json["goals"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "goals": goals,
    };
}

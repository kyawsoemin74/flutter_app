// To parse this JSON data, do
//
//     final playersquads = playersquadsFromJson(jsonString);

import 'dart:convert';

List<Playersquads> playersquadsFromJson(String str) => List<Playersquads>.from(json.decode(str).map((x) => Playersquads.fromJson(x)));

String playersquadsToJson(List<Playersquads> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Playersquads {
    Playersquads({
        this.team,
        this.players,
    });

    Team? team;
    List<Players>? players;

    factory Playersquads.fromJson(Map<String, dynamic> json) => Playersquads(
        team: Team.fromJson(json["team"]),
        players: List<Players>.from(json["players"].map((x) => Players.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "team": team!.toJson(),
        "players": List<dynamic>.from(players!.map((x) => x.toJson())),
    };
}

class Players {
    Players({
        this.id,
        this.name,
        this.age,
        this.number,
        this.position,
        this.photo,
    });

    int? id;
    String? name;
    int? age;
    int? number;
    String ?position;
    String? photo;

    factory Players.fromJson(Map<String, dynamic> json) => Players(
        id: json["id"],
        name: json["name"],
        age: json["age"],
        number: json["number"],
        position: json["position"],
        photo: json["photo"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "age": age,
        "number": number,
        "position": position,
        "photo": photo,
    };
}

class Team {
    Team({
        this.id,
        this.name,
        this.logo,
    });

    int? id;
    String? name;
    String? logo;

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
    };
}

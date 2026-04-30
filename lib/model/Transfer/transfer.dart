// To parse this JSON data, do
//
//     final transfer = transferFromJson(jsonString);

import 'dart:convert';

List<Transfer> transferFromJson(String str) => List<Transfer>.from(json.decode(str).map((x) => Transfer.fromJson(x)));

String transferToJson(List<Transfer> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Transfer {
    Transfer({
        this.player,
        this.update,
        this.transfers,
    });

    Player? player;
    DateTime ?update;
    List<TransferElement>? transfers;

    factory Transfer.fromJson(Map<String, dynamic> json) => Transfer(
        player: Player.fromJson(json["player"]),
        update: DateTime.parse(json["update"]),
        transfers: List<TransferElement>.from(json["transfers"].map((x) => TransferElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "player": player!.toJson(),
        "update": update!.toIso8601String(),
        "transfers": List<dynamic>.from(transfers!.map((x) => x.toJson())),
    };
}

class Player {
    Player({
        this.id,
        this.name,
    });

    int? id;
    String? name;

    factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class TransferElement {
    TransferElement({
        this.date,
        this.type,
        this.teams,
    });

    DateTime? date;
    String? type;
    Teams? teams;

    factory TransferElement.fromJson(Map<String, dynamic> json) => TransferElement(
        date: DateTime.parse(json["date"]),
        type: json["type"],
        teams: Teams.fromJson(json["teams"]),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "type": type,
        "teams": teams!.toJson(),
    };
}

class Teams {
    Teams({
        this.teamsIn,
        this.out,
    });

    In? teamsIn;
    In? out;

    factory Teams.fromJson(Map<String, dynamic> json) => Teams(
        teamsIn: In.fromJson(json["in"]),
        out: In.fromJson(json["out"]),
    );

    Map<String, dynamic> toJson() => {
        "in": teamsIn!.toJson(),
        "out": out!.toJson(),
    };
}

class In {
    In({
        this.id,
        this.name,
        this.logo,
    });

    int? id;
    String? name;
    String? logo;

    factory In.fromJson(Map<String, dynamic> json) => In(
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

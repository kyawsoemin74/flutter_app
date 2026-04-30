// To parse this JSON data, do
//
//     final matchpoll = matchpollFromJson(jsonString);

import 'dart:convert';

Matchpoll matchpollFromJson(String str) => Matchpoll.fromJson(json.decode(str));

String matchpollToJson(Matchpoll data) => json.encode(data.toJson());

class Matchpoll {
    Matchpoll({
        this.matchid,
        this.poll,
        this.total,
    });

    int? matchid;
    List<Poll>? poll;
    int? total;

    factory Matchpoll.fromJson(Map<String, dynamic> json) => Matchpoll(
        matchid: json["matchid"],
        poll: json["poll"] == [] ? [] : List<Poll>.from(json["poll"]!.map((x) => Poll.fromJson(x))),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "matchid": matchid,
        "poll": poll == null ? [] : List<dynamic>.from(poll!.map((x) => x.toJson())),
        "total": total,
    };
}

class Poll {
    Poll({
        this.value,
        this.name,
    });

    int? value;
    String? name;

    factory Poll.fromJson(Map<String, dynamic> json) => Poll(
        value: json["value"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "value": value,
        "name": name,
    };
}

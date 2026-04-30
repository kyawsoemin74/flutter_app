// To parse this JSON data, do
//
//     final topTeam = topTeamFromJson(jsonString);

import 'dart:convert';

List<TopTeam> topTeamFromJson(String str) => List<TopTeam>.from(json.decode(str).map((x) => TopTeam.fromJson(x)));

String topTeamToJson(List<TopTeam> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TopTeam {
    int? teamid;
    int? season;
    int? leagueid;
    String? teamname;
    String? teamlogo;

    TopTeam({
        this.teamid,
        this.season,
        this.leagueid,
        this.teamname,
        this.teamlogo,
    });

    factory TopTeam.fromJson(Map<String, dynamic> json) => TopTeam(
        teamid: json["teamid"],
        season: json["season"],
        leagueid: json["leagueid"],
        teamname: json["teamname"],
        teamlogo: json["teamlogo"],
    );

    Map<String, dynamic> toJson() => {
        "teamid": teamid,
        "season": season,
        "leagueid": leagueid,
        "teamname": teamname,
        "teamlogo": teamlogo,
    };
}

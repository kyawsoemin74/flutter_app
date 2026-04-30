// To parse this JSON data, do
//
//     final animationMatch = animationMatchFromJson(jsonString);

import 'dart:convert';

AnimationMatch animationMatchFromJson(String str) => AnimationMatch.fromJson(json.decode(str));

String animationMatchToJson(AnimationMatch data) => json.encode(data.toJson());

class AnimationMatch {
    AnimationMatch({
        this.code,
        this.message,
        this.data,
    });

    int? code;
    String? message;
    List<Datum>? data;

    factory AnimationMatch.fromJson(Map<String, dynamic> json) => AnimationMatch(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        this.matchId,
        this.leagueType,
        this.leagueId,
        this.leagueName,
        this.leagueShortName,
        this.leagueColor,
        this.subLeagueId,
        this.subLeagueName,
        this.matchTime,
        this.halfStartTime,
        this.status,
        this.homeId,
        this.homeName,
        this.awayId,
        this.awayName,
        this.homeScore,
        this.awayScore,
        this.homeHalfScore,
        this.awayHalfScore,
        this.homeRed,
        this.awayRed,
        this.homeYellow,
        this.awayYellow,
        this.homeCorner,
        this.awayCorner,
        this.homeRank,
        this.awayRank,
        this.season,
        this.stageId,
        this.round,
        this.group,
        this.location,
        this.weather,
        this.temperature,
        this.explain,
   
        this.hasLineup,
        this.neutral,
    });

    String? matchId;
    int? leagueType;
    String? leagueId;
    String? leagueName;
    String? leagueShortName;
    String? leagueColor;
    String? subLeagueId;
    String? subLeagueName;
    int? matchTime;
    int? halfStartTime;
    int? status;
    String? homeId;
    String? homeName;
    String? awayId;
    String? awayName;
    int? homeScore;
    int? awayScore;
    int? homeHalfScore;
    int? awayHalfScore;
    int? homeRed;
    int? awayRed;
    int? homeYellow;
    int? awayYellow;
    int? homeCorner;
    int? awayCorner;
    String? homeRank;
    String? awayRank;
    String? season;
    String? stageId;
    String? round;
    String? group;
    String? location;
    String? weather;
    String? temperature;
    String? explain;
    
    bool? hasLineup;
    bool? neutral;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        matchId: json["matchId"],
        leagueType: json["leagueType"],
        leagueId: json["leagueId"],
        leagueName: json["leagueName"],
        leagueShortName: json["leagueShortName"],
        leagueColor: json["leagueColor"],
        subLeagueId: json["subLeagueId"],
        subLeagueName: json["subLeagueName"],
        matchTime: json["matchTime"],
        halfStartTime: json["halfStartTime"],
        status: json["status"],
        homeId: json["homeId"],
        homeName: json["homeName"],
        awayId: json["awayId"],
        awayName: json["awayName"],
        homeScore: json["homeScore"],
        awayScore: json["awayScore"],
        homeHalfScore: json["homeHalfScore"],
        awayHalfScore: json["awayHalfScore"],
        homeRed: json["homeRed"],
        awayRed: json["awayRed"],
        homeYellow: json["homeYellow"],
        awayYellow: json["awayYellow"],
        homeCorner: json["homeCorner"],
        awayCorner: json["awayCorner"],
        homeRank: json["homeRank"],
        awayRank: json["awayRank"],
        season: json["season"],
        stageId: json["stageId"],
        round: json["round"],
        group: json["group"],
        location: json["location"],
        weather: json["weather"],
        temperature: json["temperature"],
        explain: json["explain"],
        
        hasLineup: json["hasLineup"],
        neutral: json["neutral"],
    );

    Map<String, dynamic> toJson() => {
        "matchId": matchId,
        "leagueType": leagueType,
        "leagueId": leagueId,
        "leagueName": leagueName,
        "leagueShortName": leagueShortName,
        "leagueColor": leagueColor,
        "subLeagueId": subLeagueId,
        "subLeagueName": subLeagueName,
        "matchTime": matchTime,
        "halfStartTime": halfStartTime,
        "status": status,
        "homeId": homeId,
        "homeName": homeName,
        "awayId": awayId,
        "awayName": awayName,
        "homeScore": homeScore,
        "awayScore": awayScore,
        "homeHalfScore": homeHalfScore,
        "awayHalfScore": awayHalfScore,
        "homeRed": homeRed,
        "awayRed": awayRed,
        "homeYellow": homeYellow,
        "awayYellow": awayYellow,
        "homeCorner": homeCorner,
        "awayCorner": awayCorner,
        "homeRank": homeRank,
        "awayRank": awayRank,
        "season": season,
        "stageId": stageId,
        "round": round,
        "group": group,
        "location": location,
        "weather": weather,
        "temperature": temperature,
        "explain": explain,
        
        "hasLineup": hasLineup,
        "neutral": neutral,
    };
}

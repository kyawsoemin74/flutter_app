// To parse this JSON data, do
//
//     final matchlist = matchlistFromJson(jsonString);

import 'dart:convert';

List<Matchlist> matchlistFromJson(String str) =>
    json.decode(str) is List
        ? List<Matchlist>.from(
            (json.decode(str) as List).map((x) => Matchlist.fromJson(x)))
        : [];

String matchlistToJson(List<Matchlist> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Matchlist {
  Matchlist({
    this.matchId,
    this.leagueId,
    this.leagueName,
    this.leagueLogo,
    this.country,
    this.homeTeam,
    this.homeLogo,
    this.awayTeam,
    this.awayLogo,
    this.status,
    this.matchTime,
    this.score,
    this.referee,
    this.venueName,
    this.venueCity,
    this.leagueRound,
  });

  int? matchId;
  int? leagueId;
  String? leagueName;
  String? leagueLogo;
  String? country;
  String? homeTeam;
  String? homeLogo;
  String? awayTeam;
  String? awayLogo;
  String? status;
  DateTime? matchTime;
  String? score;
  String? referee;
  String? venueName;
  String? venueCity;
  String? leagueRound;

  factory Matchlist.fromJson(Map<String, dynamic> json) => Matchlist(
        matchId: json["match_id"],
        leagueId: json["league_id"],
        leagueName: json["league_name"],
        leagueLogo: json["league_logo"],
        country: json["country"],
        homeTeam: json["home_team"],
        homeLogo: json["home_logo"],
        awayTeam: json["away_team"],
        awayLogo: json["away_logo"],
        status: json["status"],
        matchTime: json["match_time"] == null ? null : DateTime.parse(json["match_time"]),
        score: json["score"],
        referee: json["referee"],
        venueName: json["venue_name"],
        venueCity: json["venue_city"],
        leagueRound: json["league_round"],
      );

  Map<String, dynamic> toJson() => {
        "match_id": matchId,
        "league_id": leagueId,
        "league_name": leagueName,
        "league_logo": leagueLogo,
        "country": country,
        "home_team": homeTeam,
        "home_logo": homeLogo,
        "away_team": awayTeam,
        "away_logo": awayLogo,
        "status": status,
        "match_time": matchTime?.toIso8601String(),
        "score": score,
        "referee": referee,
        "venue_name": venueName,
        "venue_city": venueCity,
        "league_round": leagueRound,
      };
}

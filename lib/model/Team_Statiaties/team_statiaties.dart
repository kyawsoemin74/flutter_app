// To parse this JSON data, do
//
//     final teamstatistics = teamstatisticsFromJson(jsonString);

import 'dart:convert';

Teamstatistics teamstatisticsFromJson(String str) =>
    Teamstatistics.fromJson(json.decode(str));

String teamstatisticsToJson(Teamstatistics data) => json.encode(data.toJson());

class Teamstatistics {
  Teamstatistics({
    this.league,
    this.team,
    this.form,
    this.fixtures,
    this.goals,
    this.biggest,
    this.cleanSheet,
    this.failedToScore,
    this.penalty,
    this.lineups,
    this.cards,
  });

  League? league;
  Team? team;
  String? form;
  Fixtures? fixtures;
  TeamstatisticsGoals? goals;
  Biggest? biggest;
  CleanSheet? cleanSheet;
  CleanSheet? failedToScore;
  Penalty? penalty;
  List<Lineups>? lineups;
  Cards? cards;

  factory Teamstatistics.fromJson(Map<String, dynamic> json) => Teamstatistics(
        league: json["league"] == null ? null : League.fromJson(json["league"]),
        team: json["team"] == null ? null : Team.fromJson(json["team"]),
        form: json["form"],
        fixtures: json["fixtures"] == null
            ? null
            : Fixtures.fromJson(json["fixtures"]),
        goals: json["goals"] == null
            ? null
            : TeamstatisticsGoals.fromJson(json["goals"]),
        biggest:
            json["biggest"] == null ? null : Biggest.fromJson(json["biggest"]),
        cleanSheet: json["clean_sheet"] == null
            ? null
            : CleanSheet.fromJson(json["clean_sheet"]),
        failedToScore: json["failed_to_score"] == null
            ? null
            : CleanSheet.fromJson(json["failed_to_score"]),
        penalty:
            json["penalty"] == null ? null : Penalty.fromJson(json["penalty"]),
        lineups: json["lineups"] == null
            ? []
            : List<Lineups>.from(
                json["lineups"].map((x) => Lineups.fromJson(x))),
        cards: json["cards"] == null ? null : Cards.fromJson(json["cards"]),
      );

  Map<String, dynamic> toJson() => {
        "league": league!.toJson(),
        "team": team!.toJson(),
        "form": form,
        "fixtures": fixtures!.toJson(),
        "goals": goals!.toJson(),
        "biggest": biggest!.toJson(),
        "clean_sheet": cleanSheet!.toJson(),
        "failed_to_score": failedToScore!.toJson(),
        "penalty": penalty!.toJson(),
        "lineups": List<dynamic>.from(lineups!.map((x) => x.toJson())),
        "cards": cards!.toJson(),
      };
}

class Biggest {
  Biggest({
    this.streak,
    this.wins,
    this.loses,
    this.goals,
  });

  Streak? streak;
  Loses? wins;
  Loses? loses;
  BiggestGoals? goals;

  factory Biggest.fromJson(Map<String, dynamic> json) => Biggest(
        streak: Streak.fromJson(json["streak"]),
        wins: Loses.fromJson(json["wins"]),
        loses: Loses.fromJson(json["loses"]),
        goals: BiggestGoals.fromJson(json["goals"]),
      );

  Map<String, dynamic> toJson() => {
        "streak": streak!.toJson(),
        "wins": wins!.toJson(),
        "loses": loses!.toJson(),
        "goals": goals!.toJson(),
      };
}

class BiggestGoals {
  BiggestGoals({
    this.goalsFor,
    this.against,
  });

  PurpleAgainst? goalsFor;
  PurpleAgainst? against;

  factory BiggestGoals.fromJson(Map<String, dynamic> json) => BiggestGoals(
        goalsFor: PurpleAgainst.fromJson(json["for"]),
        against: PurpleAgainst.fromJson(json["against"]),
      );

  Map<String, dynamic> toJson() => {
        "for": goalsFor!.toJson(),
        "against": against!.toJson(),
      };
}

class PurpleAgainst {
  PurpleAgainst({
    this.home,
    this.away,
  });

  int? home;
  int? away;

  factory PurpleAgainst.fromJson(Map<String, dynamic> json) => PurpleAgainst(
        home: json["home"],
        away: json["away"],
      );

  Map<String, dynamic> toJson() => {
        "home": home,
        "away": away,
      };
}

class Loses {
  Loses({
    this.home,
    this.away,
  });

  String? home;
  String? away;

  factory Loses.fromJson(Map<String, dynamic> json) => Loses(
        home: json["home"],
        away: json["away"],
      );

  Map<String, dynamic> toJson() => {
        "home": home,
        "away": away,
      };
}

class Streak {
  Streak({
    this.wins,
    this.draws,
    this.loses,
  });

  int? wins;
  int? draws;
  int? loses;

  factory Streak.fromJson(Map<String, dynamic> json) => Streak(
        wins: json["wins"],
        draws: json["draws"],
        loses: json["loses"],
      );

  Map<String, dynamic> toJson() => {
        "wins": wins,
        "draws": draws,
        "loses": loses,
      };
}

class Cards {
  Cards({
    this.yellow,
    this.red,
  });

  Map<String, Missed>? yellow;
  Map<String, Missed>? red;

  factory Cards.fromJson(Map<String, dynamic> json) => Cards(
        yellow: Map.from(json["yellow"])
            .map((k, v) => MapEntry<String, Missed>(k, Missed.fromJson(v))),
        red: Map.from(json["red"])
            .map((k, v) => MapEntry<String, Missed>(k, Missed.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "yellow": Map.from(yellow!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "red": Map.from(red!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class Missed {
  Missed({
    this.total,
    this.percentage,
  });

  int? total;
  String? percentage;

  factory Missed.fromJson(Map<String, dynamic> json) => Missed(
        total: json["total"] == null ? null : json["total"],
        percentage: json["percentage"] == null ? null : json["percentage"],
      );

  Map<String, dynamic> toJson() => {
        "total": total == null ? null : total,
        "percentage": percentage == null ? null : percentage,
      };
}

class CleanSheet {
  CleanSheet({
    this.home,
    this.away,
    this.total,
  });

  int? home;
  int? away;
  int? total;

  factory CleanSheet.fromJson(Map<String, dynamic> json) => CleanSheet(
        home: json["home"],
        away: json["away"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "home": home,
        "away": away,
        "total": total,
      };
}

class Fixtures {
  Fixtures({
    this.played,
    this.wins,
    this.draws,
    this.loses,
  });

  CleanSheet? played;
  CleanSheet? wins;
  CleanSheet? draws;
  CleanSheet? loses;

  factory Fixtures.fromJson(Map<String, dynamic> json) => Fixtures(
        played: CleanSheet.fromJson(json["played"]),
        wins: CleanSheet.fromJson(json["wins"]),
        draws: CleanSheet.fromJson(json["draws"]),
        loses: CleanSheet.fromJson(json["loses"]),
      );

  Map<String, dynamic> toJson() => {
        "played": played!.toJson(),
        "wins": wins!.toJson(),
        "draws": draws!.toJson(),
        "loses": loses!.toJson(),
      };
}

class TeamstatisticsGoals {
  TeamstatisticsGoals({
    this.goalsFor,
    this.against,
  });

  FluffyAgainst? goalsFor;
  FluffyAgainst? against;

  factory TeamstatisticsGoals.fromJson(Map<String, dynamic> json) =>
      TeamstatisticsGoals(
        goalsFor: FluffyAgainst.fromJson(json["for"]),
        against: FluffyAgainst.fromJson(json["against"]),
      );

  Map<String, dynamic> toJson() => {
        "for": goalsFor!.toJson(),
        "against": against!.toJson(),
      };
}

class FluffyAgainst {
  FluffyAgainst({
    this.total,
    this.average,
    this.minute,
  });

  CleanSheet? total;
  Average? average;
  Map<String, Missed>? minute;

  factory FluffyAgainst.fromJson(Map<String, dynamic> json) => FluffyAgainst(
        total: CleanSheet.fromJson(json["total"]),
        average: Average.fromJson(json["average"]),
        minute: Map.from(json["minute"])
            .map((k, v) => MapEntry<String, Missed>(k, Missed.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "total": total!.toJson(),
        "average": average!.toJson(),
        "minute": Map.from(minute!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class Average {
  Average({
    this.home,
    this.away,
    this.total,
  });

  String? home;
  String? away;
  String? total;

  factory Average.fromJson(Map<String, dynamic> json) => Average(
        home: json["home"],
        away: json["away"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "home": home,
        "away": away,
        "total": total,
      };
}

class League {
  League({
    this.id,
    this.name,
    this.country,
    this.logo,
    this.flag,
    this.season,
  });

  int? id;
  String? name;
  String? country;
  String? logo;
  String? flag;
  int? season;

  factory League.fromJson(Map<String, dynamic> json) => League(
        id: json["id"],
        name: json["name"],
        country: json["country"],
        logo: json["logo"],
        flag: json["flag"],
        season: json["season"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country": country,
        "logo": logo,
        "flag": flag,
        "season": season,
      };
}

class Lineups {
  Lineups({
    this.formation,
    this.played,
  });

  String? formation;
  int? played;

  factory Lineups.fromJson(Map<String, dynamic> json) => Lineups(
        formation: json["formation"],
        played: json["played"],
      );

  Map<String, dynamic> toJson() => {
        "formation": formation,
        "played": played,
      };
}

class Penalty {
  Penalty({
    this.scored,
    this.missed,
    this.total,
  });

  Missed? scored;
  Missed? missed;
  int? total;

  factory Penalty.fromJson(Map<String, dynamic> json) => Penalty(
        scored: Missed.fromJson(json["scored"]),
        missed: Missed.fromJson(json["missed"]),
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "scored": scored!.toJson(),
        "missed": missed!.toJson(),
        "total": total,
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

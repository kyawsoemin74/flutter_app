// To parse this JSON data, do
//
//     final matchlist = matchlistFromJson(jsonString);

import 'dart:convert';

List<Matchlist> matchlistFromJson(String str) =>
    List<Matchlist>.from(json.decode(str).map((x) => Matchlist.fromJson(x)));

String matchlistToJson(List<Matchlist> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Matchlist {
  Matchlist({
    this.fixture,
    this.league,
    this.teams,
    this.goals,
    this.score,
    
  });

  Fixture? fixture;
  League? league;
  Goals? teams;
  Goals? goals;
  Score? score;


  factory Matchlist.fromJson(Map<String, dynamic> json) => Matchlist(
        fixture: Fixture.fromJson(json["fixture"]),
        league: League.fromJson(json["league"]),
        teams: Goals.fromJson(json["teams"]),
        goals: Goals.fromJson(json["goals"]),
        score: Score.fromJson(json["score"]),
       
      );

  Map<String, dynamic> toJson() => {
        "fixture": fixture!.toJson(),
        "league": league!.toJson(),
        "teams": teams!.toJson(),
        "goals": goals!.toJson(),
        "score": score!.toJson(),
        
      };
}

class Event {
  Event({
    this.time,
    this.team,
    this.player,
    this.assist,
    this.type,
    this.detail,
    this.comments,
  });

  Time? time;
  Team? team;
  Assist? player;
  Assist? assist;
  String? type;
  String? detail;
  dynamic comments;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        time: Time.fromJson(json["time"]),
        team: Team.fromJson(json["team"]),
        player: Assist.fromJson(json["player"]),
        assist: Assist.fromJson(json["assist"]),
        type: json["type"],
        detail: json["detail"],
        comments: json["comments"],
      );

  Map<String, dynamic> toJson() => {
        "time": time!.toJson(),
        "team": team!.toJson(),
        "player": player!.toJson(),
        "assist": assist!.toJson(),
        "type": type,
        "detail": detail,
        "comments": comments,
      };
}

class Assist {
  Assist({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory Assist.fromJson(Map<String, dynamic> json) => Assist(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
      };
}

class Team {
  Team({
    this.id,
    this.name,
    this.logo,
    this.winner,
  });

  int? id;
  String? name;
  String? logo;
  dynamic winner;

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
        winner: json["winner"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
        "winner": winner,
      };
}

class Time {
  Time({
    this.elapsed,
    this.extra,
  });

  int? elapsed;
  int? extra;

  factory Time.fromJson(Map<String, dynamic> json) => Time(
        elapsed: json["elapsed"],
        extra: json["extra"] == null ? null : json["extra"],
      );

  Map<String, dynamic> toJson() => {
        "elapsed": elapsed,
        "extra": extra == null ? null : extra,
      };
}

class Fixture {
  Fixture({
    this.id,
    this.referee,
    this.timezone,
    this.date,
    this.timestamp,
    this.periods,
    this.venue,
    this.status,
  });

  int? id;
  dynamic referee;
  String? timezone;
  DateTime? date;
  int? timestamp;
  Periods? periods;
  Venue? venue;
  Status? status;

  factory Fixture.fromJson(Map<String, dynamic> json) => Fixture(
        id: json["id"],
        referee: json["referee"],
        timezone: json["timezone"],
        date: DateTime.parse(json["date"]),
        timestamp: json["timestamp"],
        periods: Periods.fromJson(json["periods"]),
        venue: Venue.fromJson(json["venue"]),
        status: Status.fromJson(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "referee": referee,
        "timezone": timezone,
        "date": date!.toIso8601String(),
        "timestamp": timestamp,
        "periods": periods!.toJson(),
        "venue": venue!.toJson(),
        "status": status!.toJson(),
      };
}

class Periods {
  Periods({
    this.first,
    this.second,
  });

  int? first;
  int? second;

  factory Periods.fromJson(Map<String, dynamic> json) => Periods(
        first: json["first"],
        second: json["second"],
      );

  Map<String, dynamic> toJson() => {
        "first": first,
        "second": second,
      };
}

class Status {
  Status({
    this.long,
    this.short,
    this.elapsed,
  });

  String? long;
  String? short;
  int? elapsed;

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        long: json["long"],
        short: json["short"],
        elapsed: json["elapsed"],
      );

  Map<String, dynamic> toJson() => {
        "long": long,
        "short": short,
        "elapsed": elapsed,
      };
}

class Venue {
  Venue({
    this.id,
    this.name,
    this.city,
  });

  int? id;
  String? name;
  String? city;

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json["id"],
        name: json["name"],
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "city": city,
      };
}

class Goals {
  Goals({
    this.home,
    this.away,
  });

  dynamic home;
  dynamic away;

  factory Goals.fromJson(Map<String, dynamic> json) => Goals(
        home: json["home"],
        away: json["away"],
      );

  Map<String, dynamic> toJson() => {
        "home": home,
        "away": away,
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
    this.round,
  });

  int? id;
  String? name;
  String? country;
  String? logo;
  String? flag;
  int? season;
  String? round;

  factory League.fromJson(Map<String, dynamic> json) => League(
        id: json["id"],
        name: json["name"],
        country: json["country"],
        logo: json["logo"],
        flag: json["flag"],
        season: json["season"],
        round: json["round"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country": country,
        "logo": logo,
        "flag": flag,
        "season": season,
        "round": round,
      };
}

class Score {
  Score({
    this.halftime,
    this.fulltime,
    this.extratime,
    this.penalty,
  });

  Goals? halftime;
  Goals? fulltime;
  Goals? extratime;
  Goals? penalty;

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        halftime: Goals.fromJson(json["halftime"]),
        fulltime: Goals.fromJson(json["fulltime"]),
        extratime: Goals.fromJson(json["extratime"]),
        penalty: Goals.fromJson(json["penalty"]),
      );

  Map<String, dynamic> toJson() => {
        "halftime": halftime?.toJson(),
        "fulltime": fulltime?.toJson(),
        "extratime": extratime?.toJson(),
        "penalty": penalty?.toJson(),
      };
}

// To parse this JSON data, do
//
//     final matchlist = matchlistFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../All_League/all_league.dart';

List<Matchlist> matchlistFromJson(String str) {
  final decoded = json.decode(str);
  return decoded is List
      ? List<Matchlist>.from(
          decoded.map((x) => Matchlist.fromJson(x as Map<String, dynamic>)))
      : [];
}

String getMatchStatusDisplay(Matchlist match) => match.matchStatusDisplay;

String _formatMatchTime(String? rawDateTime) {
  if (rawDateTime == null || rawDateTime.trim().isEmpty) return '--:--';
  final text = rawDateTime.trim();

  try {
    final dateTime = DateTime.parse(text).toLocal();
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  } catch (_) {
    if (text.contains('T')) {
      final timePart = text.split('T').last.split('.').first;
      return timePart;
    }
    return text;
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

String matchlistToJson(List<Matchlist> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeagueGroup {
  LeagueGroup({
    required this.league,
    required this.matches,
    this.isExpanded = false,
    this.country,
    this.countryFlag,
  });

  final League league;
  final List<Matchlist> matches;
  bool isExpanded;
  final String? country;
  final String? countryFlag;
}

List<LeagueGroup> groupMatchesByLeague(List<Matchlist> matches) {
  final Map<int, LeagueGroup> grouped = {};

  for (final match in matches) {
    final leagueId = match.leagueId ?? 0;
    final leagueName = match.leagueName?.trim();
    final group = grouped.putIfAbsent(
      leagueId,
      () => LeagueGroup(
        league: League(
          id: leagueId == 0 ? null : leagueId,
          name: leagueName?.isNotEmpty == true ? leagueName : 'Unknown League',
          logo: match.leagueLogo,
          type: null,
        ),
        matches: [],
        country: match.country,
        countryFlag: match.countryFlag,
      ),
    );
    group.matches.add(match);
  }

  final groups = grouped.values.toList();
  groups.sort((a, b) => (a.league.name ?? '').compareTo(b.league.name ?? ''));
  return groups;
}

class Matchlist {
  Matchlist({
    this.matchId,
    this.leagueId,
    this.leagueName,
    this.leagueLogo,
    this.country,
    this.countryFlag,
    this.homeTeam,
    this.homeLogo,
    this.awayTeam,
    this.awayLogo,
    this.status,
    this.matchTime,
    this.score,
    this.elapsed,
    this.homeScore,
    this.awayScore,
    this.referee,
    this.venueName,
    this.venueCity,
    this.leagueRound,
    required this.matchStatusDisplay,
  });

  int? matchId;
  int? leagueId;
  String? leagueName;
  String? leagueLogo;
  String? country;
  String? countryFlag;
  String? homeTeam;
  String? homeLogo;
  String? awayTeam;
  String? awayLogo;
  String? status;
  String? matchTime;
  String? score;
  int? elapsed;
  int? homeScore;
  int? awayScore;
  String? referee;
  String? venueName;
  String? venueCity;
  String? leagueRound;
  String matchStatusDisplay;

  String get _normalizedStatus => status?.trim().toUpperCase() ?? '';

  bool get isFinished {
    final code = _normalizedStatus;
    return code == 'FT' || code == 'AET' || code == 'PEN';
  }

  bool get isPostponed {
    final code = _normalizedStatus;
    return code == 'PST' || code == 'PPD' || code == 'POSTPONED';
  }

  bool get isHalfTime => _normalizedStatus == 'HT';

  bool get isActiveLivePeriod {
    final code = _normalizedStatus;
    return code == '1H' || code == '2H';
  }

  bool get isLive {
    final code = _normalizedStatus;
    return isHalfTime || isActiveLivePeriod || code == 'ET' || code == 'LIVE' || int.tryParse(code) != null;
  }

  bool get isUpcoming => !isFinished && !isLive && !isPostponed;

  String get displayMatchTime => _formatMatchTime(matchTime);

  factory Matchlist.fromJson(Map<String, dynamic> json) {
    try {
      final statusRaw = json['status'];
      String? statusValue;
      if (statusRaw is String) {
        statusValue = statusRaw.trim();
      } else if (statusRaw is Map) {
        statusValue = statusRaw['short']?.toString() ?? statusRaw['long']?.toString();
      }

      final elapsedValue = _toInt(json['elapsed'] ?? json['status']?['elapsed'] ?? json['fixture']?['status']?['elapsed'] ?? json['time']?['elapsed']);

      int? homeScoreValue = _toInt(json['home_score'] ?? json['homeScore'] ?? json['goals']?['home']);
      int? awayScoreValue = _toInt(json['away_score'] ?? json['awayScore'] ?? json['goals']?['away']);

      final scoreValue = json['score'];
      if ((homeScoreValue == null || awayScoreValue == null) && scoreValue is Map) {
        homeScoreValue ??= _toInt(scoreValue['home'] ?? scoreValue['home_score'] ?? scoreValue['homeScore']);
        awayScoreValue ??= _toInt(scoreValue['away'] ?? scoreValue['away_score'] ?? scoreValue['awayScore']);
      }
      if ((homeScoreValue == null || awayScoreValue == null) && scoreValue is String) {
        final parts = scoreValue.split('-').map((part) => part.trim()).toList();
        if (parts.length == 2) {
          homeScoreValue ??= _toInt(parts[0]);
          awayScoreValue ??= _toInt(parts[1]);
        }
      }

      final matchTimeValue = json['match_time']?.toString();
      final statusText = statusValue?.trim().toUpperCase() ?? '';

      return Matchlist(
        matchId: _toInt(json['match_id'] ?? json['fixture_id']),
        leagueId: _toInt(json['league_id'] ?? json['leagueid']),
        leagueName: json['league_name'] ?? json['leagueName'],
        leagueLogo: json['league_logo'] ?? json['leagueLogo'],
        country: json['country'] ?? json['country_name'] ?? json['countryName'],
        countryFlag: json['country_flag'] ?? json['countryFlag'],
        homeTeam: json['home_team'] ?? json['homeTeam'],
        homeLogo: json['home_logo'] ?? json['homeLogo'] ?? json['home_team_logo'] ?? json['homeTeamLogo'],
        awayTeam: json['away_team'] ?? json['awayTeam'],
        awayLogo: json['away_logo'] ?? json['awayLogo'] ?? json['away_team_logo'] ?? json['awayTeamLogo'],
        status: statusValue,
        matchTime: matchTimeValue,
        score: scoreValue?.toString(),
        elapsed: elapsedValue,
        homeScore: homeScoreValue,
        awayScore: awayScoreValue,
        referee: json['referee']?.toString(),
        venueName: json['venue_name']?.toString(),
        venueCity: json['venue_city']?.toString(),
        leagueRound: json['league_round']?.toString(),
        matchStatusDisplay: _computeStatusDisplay(
          statusText,
          elapsedValue,
          homeScoreValue,
          awayScoreValue,
          scoreValue?.toString(),
          matchTimeValue,
        ),
      );
    } catch (e) {
      debugPrint("Error parsing Matchlist from JSON: $e, JSON: $json");
      // Return a minimal Matchlist to avoid crashing the list
      return Matchlist(
        matchId: null,
        leagueId: null,
        leagueName: 'Unknown League',
        leagueLogo: null,
        country: 'Unknown Country',
        countryFlag: null,
        homeTeam: 'Unknown Home',
        homeLogo: null,
        awayTeam: 'Unknown Away',
        awayLogo: null,
        status: 'NS',
        matchTime: null,
        score: null,
        elapsed: null,
        homeScore: null,
        awayScore: null,
        referee: null,
        venueName: null,
        venueCity: null,
        leagueRound: null,
        matchStatusDisplay: '--:--',
      );
    }
  }

  static String _computeStatusDisplay(
    String status,
    int? elapsed,
    int? homeScore,
    int? awayScore,
    String? score,
    String? matchTime,
  ) {
    final isLiveStatus = status == 'HT' || status == '1H' || status == '2H' || status == 'ET' || status == 'LIVE' || int.tryParse(status) != null;
    if (isLiveStatus) {
      final home = homeScore ?? 0;
      final away = awayScore ?? 0;
      return '$home - $away';
    }

    final scoreText = (homeScore != null && awayScore != null) ? '$homeScore - $awayScore' : null;

    if (status == 'PST' || status == 'PPD' || status == 'POSTPONED') {
      return 'Postponed';
    }

    if (status == 'FT' || status == 'AET' || status == 'PEN') {
      return scoreText ?? (score?.trim().isNotEmpty == true ? score!.trim() : 'FT');
    }

    if (status == '1H' || status == '2H' || status == 'ET') {
      final elapsedText = elapsed != null ? "$elapsed'" : status;
      return scoreText != null ? '$elapsedText ($scoreText)' : elapsedText;
    }

    if (status == 'NS' || status.isEmpty) {
      return _formatMatchTime(matchTime);
    }

    return status;
  }

  Map<String, dynamic> toJson() => {
        'match_id': matchId,
        'league_id': leagueId,
        'league_name': leagueName,
        'league_logo': leagueLogo,
        'country': country,
        'country_name': country,
        'countryFlag': countryFlag,
        'country_flag': countryFlag,
        'home_team': homeTeam,
        'home_logo': homeLogo,
        'home_team_logo': homeLogo,
        'away_team': awayTeam,
        'away_logo': awayLogo,
        'away_team_logo': awayLogo,
        'status': status,
        'match_time': matchTime,
        'score': score,
        'elapsed': elapsed,
        'home_score': homeScore,
        'away_score': awayScore,
        'referee': referee,
        'venue_name': venueName,
        'venue_city': venueCity,
        'league_round': leagueRound,
      };
}


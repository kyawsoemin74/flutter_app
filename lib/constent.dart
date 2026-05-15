import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Custom_Model/leaguemathc.dart';
import 'model/MAtchlist/matchlist.dart';

// Global theme color definition for matchdetails.dart
const Color color1 = Color(0xFF102a4a);

class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // --- API & Network ---
  static const String baseUrl = "https://kyawsoemin.com";
  static const String api = "fover2026";

  // API Headers Getter
  static Map<String, String> get headers => {
        'content-type': 'application/json',
        'accept': 'application/json',
        'X-API-KEY': api,
      };

  // --- UI Theme & Styling ---
  static const Color scaffoldBgColor = Color(0xFF121212);
  static const Color glassEffectColor = Color(0xFF1E1E1E);
  static final String appName = "Fover".tr;

  // --- Default Fallback Data ---
  static int defaultLeagueId = 1;
  static String defaultLeagueName = "World Cup";
  static int defaultSeason = 2022;

  // Endpoints path များရှိပါက ဒီမှာ ဆက်လက်ထည့်နိုင်သည်
  static const String matchesLiveEndpoint = "/api/matches/live";
  static const String allMatchesEndpoint = "/api/matches/";
  
  // Dynamic endpoints
  static String matchesByDateEndpoint(String date) => "/api/matches/date/$date";
  static String matchDetailsEndpoint(String id) => "/api/matches/$id";
  static String matchEventsEndpoint(String id) => "/api/matches/$id/events";
  static String matchLineupEndpoint(String id) => "/api/matches/$id/lineup";
  static String matchH2HEndpoint(String id) => "/api/matches/$id/h2h";
  static String matchOddsEndpoint(String id) => "/api/matches/$id/odds";
  
  static const String adsEndpoint = '/api/ads/';
  static const String newsLatestEndpoint = "/api/news/latest";
  static const String newsTransfersEndpoint = "/api/news/transfers";
  static const String newsTipsEndpoint = "/api/news/tips";
}

// အောက်ပါ Helper function များသည် logic ပိုင်းဖြစ်သောကြောင့် 
// အပြင်မှာထားခြင်း သို့မဟုတ် Utility class တစ်ခုထဲသို့ ပြောင်းရွှေ့ခြင်းက ပိုသင့်တော်ပါသည်။

Duration ftmatchdurationdata(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return Duration.zero;
  }
  try {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final seconds = date.difference(now).inSeconds;
    return Duration(seconds: seconds);
  } catch (_) {
    return Duration.zero;
  }
}

String matchstatus({String? sort}) {
  if (sort == "NS") {
    return "fix";
  }
  if (sort == "SUSP") {
    return "fix";
  }
  if (sort == "FT") {
    return "rec";
  }
  if (sort == "1H") {
    return "live";
  }
  if (sort == "HT") {
    return "live";
  }
  if (sort == "2H") {
    return "live";
  }
  if (sort == "ET") {
    return "live";
  }
  if (sort == "BT") {
    return "live";
  }
  if (sort == "P") {
    return "live";
  }
  if (sort == "LIVE") {
    return "live";
  }
  if (sort == "AET") {
    return "rec";
  }
  if (sort == "PEN") {
    return "rec";
  }
  return "fix";
}

matchfilterbyleague(List<dynamic> args) {
  SendPort sendPort = args[0];
  var matchlist = args[1] as List<Matchlist>;
  var status = args[2];

  final Map<int, List<Matchlist>> leagueMap = {};
  for (final match in matchlist) {
    final leagueId = match.leagueId;
    if (leagueId == null) continue;
    leagueMap.putIfAbsent(leagueId, () => []).add(match);
  }

  final leaguematch = <Leaguematch>[];
  leagueMap.forEach((leagueId, matches) {
    final filtered = status != null
        ? matches.where((element) => element.status == status).toList()
        : matches;
    if (filtered.isNotEmpty) {
      leaguematch.add(Leaguematch(leagueid: leagueId, allmatch: filtered));
    }
  });

  sendPort.send(leaguematch);
}

List<Leaguematch> filterMatchesByLeague(List<dynamic> args) {
  var matchlist = args[0] as List<Matchlist>;
  var status = args[1] as String?;

  final Map<int, List<Matchlist>> leagueMap = {};
  for (final match in matchlist) {
    final leagueId = match.leagueId;
    if (leagueId == null) continue;
    if (status == null || match.status == status) {
      leagueMap.putIfAbsent(leagueId, () => []).add(match);
    }
  }

  final leaguematch = <Leaguematch>[];
  leagueMap.forEach((leagueId, matches) {
    if (matches.isNotEmpty) {
      leaguematch.add(Leaguematch(leagueid: leagueId, allmatch: matches));
    }
  });

  return leaguematch;
}

List<Leaguematch> parseAndGroupMatches(Map<String, dynamic> args) {
  final jsonString = args['jsonString'] as String;
  final status = args['status'] as String?;
  final decoded = jsonDecode(jsonString);

  final payload = decoded is List
      ? decoded
      : decoded is Map
          ? decoded['data'] ?? decoded['results'] ?? decoded['result'] ?? []
          : [];

  if (payload is! List) return <Leaguematch>[];

  final matches = <Matchlist>[];
  for (final item in payload) {
    if (item is Map<String, dynamic>) {
      matches.add(Matchlist.fromJson(item));
    } else if (item is Map) {
      matches.add(Matchlist.fromJson(Map<String, dynamic>.from(item)));
    }
  }

  return filterMatchesByLeague([matches, status]);
}

// Updated at 2026-05-10
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:football_xt_latest/constent.dart';
import '../api/apihelp.dart';
import '../model/Headtohead/headtohead.dart';
import '../model/SingleFixture/singlefixture.dart';
import '../model/MatchEvent/matchevent.dart';
import '../model/Odd/odd.dart';
import '../model/MAtchlist/matchlist.dart';

class MatchDetailsResult {
  final int statusCode;
  final Matchlist? match;

  MatchDetailsResult({required this.statusCode, this.match});
}

class MatchLineupResult {
  final List<Lineups> lineups;
  final bool noLineupAvailable;
  final int results;

  MatchLineupResult({
    required this.lineups,
    required this.noLineupAvailable,
    required this.results,
  });
}

class MatchDetailsService {
  Future<MatchDetailsResult> getMatchById(int id) async {
    final idString = id.toString();
    final endpoint = AppConfig.matchDetailsEndpoint(idString);
    final fullUrl = '${AppConfig.baseUrl}$endpoint';
    debugPrint('Full Request URL: $fullUrl');

    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final match = Matchlist.fromJson(jsonData);
        return MatchDetailsResult(statusCode: 200, match: match);
      }
      debugPrint('MatchDetailsService getMatchById non-200 status: ${response.statusCode}');
      return MatchDetailsResult(statusCode: response.statusCode, match: null);
    } catch (e) {
      debugPrint("MatchDetailsService getMatchById Error: $e");
      return MatchDetailsResult(statusCode: 500, match: null);
    }
  }

  Future<List<Odd>> getMatchOdds(int id) async {
    final endpoint = AppConfig.matchOddsEndpoint(id.toString());
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List
            ? decoded
            : (decoded['odds'] ?? decoded['data'] ?? decoded['result'] ?? []);
        if (list is List) {
          return list.map<Odd>((item) => Odd.fromJson(item as Map<String, dynamic>)).toList();
        }
        debugPrint('MatchDetailsService getMatchOdds: Expected List but got ${list.runtimeType}');
      } else {
        debugPrint('MatchDetailsService getMatchOdds non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MatchDetailsService getMatchOdds Error: $e');
    }
    throw Exception('Unable to load odds');
  }

  Future<List<Matchevent>> getMatchEvents(int id) async {
    final endpoint = AppConfig.matchEventsEndpoint(id.toString());
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      debugPrint('EVENT API REQUEST: $endpoint');
      debugPrint('EVENT API STATUS: ${response.statusCode}');
      debugPrint('EVENT API RESPONSE: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List
            ? decoded
            : (decoded['response'] ?? decoded['data'] ?? decoded['result'] ?? []);
        if (list is List) {
          final parsed = list.map<Matchevent>((item) => Matchevent.fromJson(item)).toList();
          debugPrint('EVENT API PARSED: ${parsed.length} events');
          return parsed;
        }
        debugPrint('MatchDetailsService getMatchEvents: Expected List but got ${list.runtimeType}');
      } else {
        debugPrint('MatchDetailsService getMatchEvents non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MatchDetailsService getMatchEvents Error: $e');
    }
    return [];
  }

  Future<MatchLineupResult> getMatchLineup(int id) async {
    final endpoint = AppConfig.matchLineupEndpoint(id.toString());
    debugPrint('LINEUP REQUEST: $endpoint');
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      debugPrint('LINEUP STATUS: ${response.statusCode}');
      debugPrint('LINEUP RESPONSE: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded is Map<String, dynamic> ? decoded['results'] ?? 0 : 0;
        final list = decoded is List
            ? decoded
            : (decoded['response'] ?? decoded['data'] ?? decoded['result'] ?? []);
        debugPrint('LINEUP RESULTS: $results');
        if (list is List) {
          final parsed = list.map<Lineups>((item) => Lineups.fromJson(item)).toList();
          debugPrint('LINEUP PARSED COUNT: ${parsed.length}');
          return MatchLineupResult(
            lineups: parsed,
            noLineupAvailable: results == 0 || parsed.isEmpty,
            results: results,
          );
        }
        debugPrint('MatchDetailsService getMatchLineup: Expected List but got ${list.runtimeType}');
      } else {
        debugPrint('MatchDetailsService getMatchLineup non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MatchDetailsService getMatchLineup Error: $e');
    }
    return MatchLineupResult(lineups: [], noLineupAvailable: false, results: 0);
  }

  Future<List<HeadtoHead>> getMatchH2H(int id) async {
    final endpoint = AppConfig.matchH2HEndpoint(id.toString());
    final fullUrl = '${AppConfig.baseUrl}$endpoint';
    debugPrint('H2H REQUEST: $fullUrl');
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      debugPrint('H2H RESPONSE STATUS: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List
            ? decoded
            : (decoded['response'] ?? decoded['data'] ?? decoded['result'] ?? []);
        if (list is List) {
          final parsed = list.map<HeadtoHead>((item) => HeadtoHead.fromJson(item)).toList();
          debugPrint('H2H RESULT COUNT: ${parsed.length}');
          if (parsed.isEmpty) {
            debugPrint('H2H EMPTY RESPONSE DETECTED');
          }
          return parsed;
        }
        debugPrint('MatchDetailsService getMatchH2H: Expected List but got ${list.runtimeType}');
      } else {
        debugPrint('MatchDetailsService getMatchH2H non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MatchDetailsService getMatchH2H Error: $e');
    }
    debugPrint('H2H RESULT COUNT: 0');
    return [];
  }
}
// Updated at 2026-05-10
import 'dart:convert';
import 'package:football_xt_latest/constent.dart';
import '../api/apihelp.dart';
import '../model/Headtohead/headtohead.dart';
import '../model/Lineup/lineup.dart';
import '../model/MatchEvent/matchevent.dart';
import '../model/Odd/odd.dart';
import '../model/MAtchlist/matchlist.dart';

class MatchDetailsResult {
  final int statusCode;
  final Matchlist? match;

  MatchDetailsResult({required this.statusCode, this.match});
}

class MatchDetailsService {
  Future<MatchDetailsResult> getMatchById(int id) async {
    final idString = id.toString();
    final endpoint = AppConfig.matchDetailsEndpoint(idString);
    final fullUrl = '${AppConfig.baseUrl}$endpoint';
    print('Full Request URL: $fullUrl');

    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final match = Matchlist.fromJson(jsonData);
        return MatchDetailsResult(statusCode: 200, match: match);
      }
      print('MatchDetailsService getMatchById non-200 status: ${response.statusCode}');
      return MatchDetailsResult(statusCode: response.statusCode, match: null);
    } catch (e) {
      print("MatchDetailsService getMatchById Error: $e");
      return MatchDetailsResult(statusCode: 500, match: null);
    }
  }

  Future<List<Odd>> getMatchOdds(int id) async {
    final endpoint = AppConfig.matchOddsEndpoint(id.toString());
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List ? decoded : (decoded['data'] ?? decoded['result'] ?? []);
        if (list is List) {
          return list.map<Odd>((item) => Odd.fromJson(item)).toList();
        }
        print('MatchDetailsService getMatchOdds: Expected List but got ${list.runtimeType}');
      } else {
        print('MatchDetailsService getMatchOdds non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      print('MatchDetailsService getMatchOdds Error: $e');
    }
    return [];
  }

  Future<List<Matchevent>> getMatchEvents(int id) async {
    final endpoint = AppConfig.matchEventsEndpoint(id.toString());
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List ? decoded : (decoded['data'] ?? decoded['result'] ?? []);
        if (list is List) {
          return list.map<Matchevent>((item) => Matchevent.fromJson(item)).toList();
        }
        print('MatchDetailsService getMatchEvents: Expected List but got ${list.runtimeType}');
      } else {
        print('MatchDetailsService getMatchEvents non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      print('MatchDetailsService getMatchEvents Error: $e');
    }
    return [];
  }

  Future<List<Lineup>> getMatchLineup(int id) async {
    final endpoint = AppConfig.matchLineupEndpoint(id.toString());
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List ? decoded : (decoded['data'] ?? decoded['result'] ?? []);
        if (list is List) {
          return list.map<Lineup>((item) => Lineup.fromJson(item)).toList();
        }
        print('MatchDetailsService getMatchLineup: Expected List but got ${list.runtimeType}');
      } else {
        print('MatchDetailsService getMatchLineup non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      print('MatchDetailsService getMatchLineup Error: $e');
    }
    return [];
  }

  Future<List<HeadtoHead>> getMatchH2H(int id) async {
    final endpoint = AppConfig.matchH2HEndpoint(id.toString());
    try {
      final response = await ApiHelp.get(ENDPOINTURL: endpoint);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List ? decoded : (decoded['data'] ?? decoded['result'] ?? []);
        if (list is List) {
          return list.map<HeadtoHead>((item) => HeadtoHead.fromJson(item)).toList();
        }
        print('MatchDetailsService getMatchH2H: Expected List but got ${list.runtimeType}');
      } else {
        print('MatchDetailsService getMatchH2H non-200 status: ${response.statusCode}');
      }
    } catch (e) {
      print('MatchDetailsService getMatchH2H Error: $e');
    }
    return [];
  }
}
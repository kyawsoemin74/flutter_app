import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:football_xt_latest/model/MAtchlist/matchlist.dart';

import '../Custom_Model/leaguemathc.dart';
import '../Httpservice/league.dart';
import '../Httpservice/m3u8.dart';
import '../Httpservice/standing.dart';
import '../Httpservice/topscore.dart';
import '../Httpservice/fixturematch.dart';
import '../Httpservice/livematch.dart';
import '../Httpservice/singlefixturematch.dart';
import '../Httpservice/match_details.dart';
import '../model/All_League/all_league.dart';
import '../model/All_League/all_league.dart' as all_league;
import '../model/Odd/odd.dart';
import '../model/Headtohead/headtohead.dart';
import '../model/LeagueFixture/leaguefixture.dart';
import '../model/Lineup/lineup.dart';
import '../model/M3u8/livestream2.dart';
import '../model/MatchEvent/matchevent.dart';
import '../model/SingleFixture/singlefixture.dart';
import '../model/Standings/standings.dart';
import '../model/Top_Score/top_score.dart';

List<LeagueGroup> groupMatchesByLeagueSync(List<Matchlist> matches) {
  final Map<int, LeagueGroup> grouped = {};

  for (final match in matches) {
    final leagueId = match.leagueId ?? 0;
    final leagueName = match.leagueName?.trim();
    final group = grouped.putIfAbsent(
      leagueId,
      () => LeagueGroup(
        league: all_league.League(
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

class MatchProvider extends ChangeNotifier {
  // List<Leaguematch> leagueLivematch = [];
  List<Leaguematch> livematch = [];
  Matchlist? selectedMatch;
  Matchlist? singleMatchData;
  bool isLoadingMatchDetails = false;

  Future getlivematch() async {
    try {
      final result = await HttpLivematch().getlivematch();
      livematch = result ?? [];
      debugPrint("Provider livematch length: ${livematch.length}");
    } catch (e) {
      debugPrint("Provider getlivematch Error: $e");
    }
    notifyListeners();
  }

  List<Leaguematch> todayfixture = [];

  bool fixtureloading = false;

  Future gettodayfixturematch({String? date}) async {
    fixtureloading = true;
    notifyListeners();
    try {
      todayfixture = await HttpFixturmatch().getFutureMatch(date: date);
    } catch (e) {
      debugPrint("Provider gettodayfixturematch Error: $e");
      todayfixture = [];
    }
    fixtureloading = false;
    notifyListeners();
  }

  List<Leaguematch> allfixturematch = [];

  bool allfixturematchloading = false;

  List<LeagueGroup> groupedAllFixtureMatches = [];

  String? fixtureError;

  Future getfixturematch({String? date}) async {
    allfixturematchloading = true;
    fixtureError = null; // Reset error
    notifyListeners();
    try {
      allfixturematch = await HttpFixturmatch().getFutureMatch(date: date);
      debugPrint("Provider allfixturematch length: ${allfixturematch.length}");

      // Compute flattened and grouped here to avoid repeated computations
      final flattened = allfixturematch.expand((group) => group.allmatch ?? <Matchlist>[]).toList();
      groupedAllFixtureMatches = await compute(groupMatchesByLeagueSync, flattened);
    } catch (e) {
      debugPrint("Provider getfixturematch Error: $e");
      allfixturematch = [];
      groupedAllFixtureMatches = [];
      fixtureError = e.toString(); // Set error message
    }
    allfixturematchloading = false;
    notifyListeners();
  }

  List<Singlefixture> singlematch = [];

  Future getsinglematchinfo(int fixtureid) async {
    try {
      final result = await HttpSinglefixture().getsinglefixture(fixtureid);
      singlematch = result ?? [];
    } catch (e) {
      debugPrint("Provider getsinglematchinfo Error: $e");
      singlematch = [];
    }
    notifyListeners();
  }

  List<Odd> odds = [];
  bool isLoadingOdds = false;

  Future<void> getOdds({int? matchid}) async {
    if (matchid == null) return;
    isLoadingOdds = true;
    notifyListeners();
    try {
      odds = await MatchDetailsService().getMatchOdds(matchid);
    } catch (e) {
      debugPrint("Provider getOdds Error: $e");
      odds = [];
    }
    isLoadingOdds = false;
    notifyListeners();
  }

  List<Matchevent> events = [];
  bool isLoadingEvents = false;

  Future<void> getMatchEvents({int? matchid}) async {
    if (matchid == null) return;
    isLoadingEvents = true;
    notifyListeners();
    try {
      events = await MatchDetailsService().getMatchEvents(matchid);
    } catch (e) {
      debugPrint("Provider getMatchEvents Error: $e");
      events = [];
    }
    isLoadingEvents = false;
    notifyListeners();
  }

  List<Lineup> lineups = [];
  bool isLoadingLineup = false;

  Future<void> getMatchLineup({int? matchid}) async {
    if (matchid == null) return;
    isLoadingLineup = true;
    notifyListeners();
    try {
      lineups = await MatchDetailsService().getMatchLineup(matchid);
    } catch (e) {
      debugPrint("Provider getMatchLineup Error: $e");
      lineups = [];
    }
    isLoadingLineup = false;
    notifyListeners();
  }

  List<HeadtoHead> h2h = [];
  bool isLoadingH2H = false;

  Future<void> geth2h({int? matchid}) async {
    if (matchid == null) return;
    isLoadingH2H = true;
    notifyListeners();
    try {
      h2h = await MatchDetailsService().getMatchH2H(matchid);
    } catch (e) {
      debugPrint("Provider geth2h Error: $e");
      h2h = [];
    }
    isLoadingH2H = false;
    notifyListeners();
  }

  List<Allleague> allleague = [];

  Future getallleague() async {
    try {
      final result = await HttpLeague().getallleague();
      allleague = result ?? [];
    } catch (e) {
      debugPrint("Provider getallleague Error: $e");
    }
    notifyListeners();
  }

  List<Leaguefixture> leaguefixture = [];

  Future getleaguefixture({int? leagueid, int? season}) async {
    try {
      final result = await HttpLeague().getleaguefixture(leagueid: leagueid, season: season);
      leaguefixture = result ?? [];
    } catch (e) {
      debugPrint("Provider getleaguefixture Error: $e");
    }
    notifyListeners();
  }

  List<Standings> standing = [];

  Future getstanding({int? leagueid, int? season}) async {
    try {
      final result = await Httpstanding().getstanding(leagueid: leagueid, season: season);
      standing = result ?? [];
    } catch (e) {
      debugPrint("Provider getstanding Error: $e");
    }
    notifyListeners();
  }

  List<TopScore>? topscore = [];

  Future gettopscore({int? leagueid, int? season}) async {
    try {
      topscore = await Httptopscore().gettopscore(leagueid: leagueid, season: season) ?? [];
    } catch (e) {
      debugPrint("Provider gettopscore Error: $e");
      topscore = [];
    }
    notifyListeners();
  }

  List<Leaguematch>? custommatch = [];
  List<Allleague> customleague = [];
  List<Matchlist>? alllivematch = [];
  Future getcustomlivematch() async {
    try {
      custommatch = await HttpLivematch().getlivematch() ?? [];
      alllivematch = await HttpLivematch().getalllivematch() ?? [];
    } catch (e) {
      debugPrint("Provider getcustomlivematch Error: $e");
    }
    notifyListeners();
  }

  List<LiveStream2>? liveStream2;
  bool steamload = false;
  Future getlivestream() async {
    try {
      liveStream2 = await HttpM3u8().getlivestream2() ?? [];
    } catch (e) {
      debugPrint("Provider getlivestream Error: $e");
      liveStream2 = [];
    }
    notifyListeners();
  }

  Future<void> fetchMatchDetails(int id) async {
    isLoadingMatchDetails = true;
    notifyListeners();
    try {
      final result = await MatchDetailsService().getMatchById(id);
      if (result.statusCode == 200) {
        singleMatchData = result.match;
      } else {
        singleMatchData = null;
        debugPrint('Provider fetchMatchDetails failed with status: ${result.statusCode}');
      }
    } catch (e) {
      debugPrint("Provider fetchMatchDetails Error: $e");
      singleMatchData = null;
    } finally {
      isLoadingMatchDetails = false;
      notifyListeners();
    }
  }
}

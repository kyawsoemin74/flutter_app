import 'package:flutter/material.dart';
import 'package:football_xt_latest/model/MAtchlist/matchlist.dart';


import '../Custom_Model/leaguemathc.dart';
import '../Httpservice/league.dart';
import '../Httpservice/m3u8.dart';
import '../Httpservice/matchevent.dart';
import '../Httpservice/playerstatistic.dart';
import '../Httpservice/standing.dart';
import '../Httpservice/statistic.dart';
import '../Httpservice/topscore.dart';
import '../Httpservice/fixturematch.dart';
import '../Httpservice/h2h.dart';
import '../Httpservice/lineup.dart';
import '../Httpservice/livematch.dart';
import '../Httpservice/singlefixturematch.dart';
import '../model/All_League/all_league.dart';
import '../model/Headtohead/headtohead.dart';
import '../model/LeagueFixture/leaguefixture.dart';
import '../model/Lineup/lineup.dart';
import '../model/M3u8/livestream2.dart';
import '../model/SingleFixture/singlefixture.dart';
import '../model/Standings/standings.dart';
import '../model/Top_Score/top_score.dart';

class MatchProvider extends ChangeNotifier {
  // List<Leaguematch> leagueLivematch = [];
  List<Leaguematch> livematch = [];

  Future getlivematch() async {
    try {
      final result = await HttpLivematch().getlivematch();
      livematch = result ?? [];
    } catch (e) {
      debugPrint("Provider getlivematch Error: $e");
    }
    notifyListeners();
  }

  List<Leaguematch> todayfixture = [];

  bool fixtureloading = false;

  Future gettodayfixturematch({String? date}) async {
    fixtureloading = true;
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

  Future getfixturematch({String? date}) async {
    allfixturematchloading = true;
    try {
      allfixturematch = await HttpFixturmatch().getFutureMatch(date: date);
    } catch (e) {
      debugPrint("Provider getfixturematch Error: $e");
      allfixturematch = [];
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
    }
    notifyListeners();
  }

  List<HeadtoHead> h2h = [];

  Future geth2h({int? teamid1, int? teamid2}) async {
    try {
      final result = await Httph2h().getheadtohead(teamid1: teamid1, teamid2: teamid2);
      h2h = result ?? [];
    } catch (e) {
      debugPrint("Provider geth2h Error: $e");
    }
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
}

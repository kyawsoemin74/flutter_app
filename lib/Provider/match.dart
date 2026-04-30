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
    livematch = (await HttpLivematch().getlivematch())!;
    notifyListeners();
  }

  List<Leaguematch> todayfixture = [];

  bool fixtureloading = false;

  Future gettodayfixturematch({String? date}) async {
    fixtureloading = true;
    todayfixture = (await HttpFixturmatch().getFutureMatch(date: date));
    fixtureloading = false;
    notifyListeners();
  }

  List<Leaguematch> allfixturematch = [];

  bool allfixturematchloading = false;

  Future getfixturematch({String? date}) async {
    allfixturematchloading = true;
    allfixturematch = (await HttpFixturmatch().getFutureMatch(date: date));
    allfixturematchloading = false;
    notifyListeners();
  }

  List<Singlefixture> singlematch = [];

  Future getsinglematchinfo(int fixtureid) async {
    singlematch = (await HttpSinglefixture().getsinglefixture(fixtureid))!;
    notifyListeners();
  }

  List<HeadtoHead> h2h = [];

  Future geth2h({int? teamid1, int? teamid2}) async {
    h2h = (await Httph2h().getheadtohead(teamid1: teamid1, teamid2: teamid2))!;
    notifyListeners();
  }

  // List<Lineup> lineup = [];

  // Future getslineup(int fixtureid) async {
  //   lineup = (await Httplineup().getlineup(fixtureid))!;
  //   notifyListeners();
  // }

  // List<Matchstatistics> statistic = [];

  // Future getstatis(int fixutreid) async {
  //   statistic = (await HttpStatistic().getmatchstatistics(fixutreid))!;
  //   notifyListeners();
  // }

  // List<Playerstatistics> playerstatics = [];

  // Future getplayerstatics(int fixutreid) async {
  //   playerstatics =
  //       (await HttpPlayerstatistic().getplayerstatistics(fixutreid))!;
  //   notifyListeners();
  // }

  // List<Matchevent> matchevent = [];

  // Future getmatchevent(int fixtureid) async {
  //   matchevent = (await Httpmatchevent().getmatchevent(fixtureid))!;
  //   notifyListeners();
  // }

  List<Allleague> allleague = [];

  Future getallleague() async {
    allleague = (await HttpLeague().getallleague())!;
    notifyListeners();
  }

  List<Leaguefixture> leaguefixture = [];

  Future getleaguefixture({int? leagueid, int? season}) async {
    leaguefixture = (await HttpLeague()
        .getleaguefixture(leagueid: leagueid, season: season))!;
    notifyListeners();
  }

  List<Standings> standing = [];

  Future getstanding({int? leagueid, int? season}) async {
    standing =
        (await Httpstanding().getstanding(leagueid: leagueid, season: season))!;
    notifyListeners();
  }

  List<TopScore>? topscore = [];

  Future gettopscore({int? leagueid, int? season}) async {
    topscore =
        (await Httptopscore().gettopscore(leagueid: leagueid, season: season));
    notifyListeners();
  }

  List<Leaguematch>? custommatch = [];
  List<Allleague> customleague = [];
  List<Matchlist>? alllivematch = [];
  Future getcustomlivematch() async {
    custommatch = (await HttpLivematch().getlivematch())!;
    alllivematch = await HttpLivematch().getalllivematch();

    // var match = await HttpFixturmatch().getFutureMatch(date: date);

    // if (status == "live") {
    //   for (var i = 0; i < leagueid!.live!.length; i++) {
    //     customleague.addAll(allleague!
    //         .where(
    //             (element) => element.league!.id == leagueid.live![i].leagueid)
    //         .toList());
    //     custommatch.addAll(match!
    //         .where(
    //             (element) => element.league!.id == leagueid.live![i].leagueid)
    //         .toList());
    //   }
    // } else {
    //   for (var i = 0; i < leagueid!.fixture!.length; i++) {
    //     customleague.addAll(allleague!
    //         .where((element) =>
    //             element.league!.id == leagueid.fixture![i].leagueid)
    //         .toList());
    //     custommatch.addAll(match!
    //         .where((element) =>
    //             element.league!.id == leagueid.fixture![i].leagueid)
    //         .toList());
    //   }
    // }
    notifyListeners();
  }

  List<LiveStream2>? liveStream2;
  bool steamload = false;
  Future getlivestream() async {
    liveStream2 = (await HttpM3u8().getlivestream2())!;

    notifyListeners();
  }
}

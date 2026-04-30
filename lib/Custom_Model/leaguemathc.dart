
import '../model/All_League/all_league.dart';
import '../model/MAtchlist/matchlist.dart';

class Leaguematch {
  Leaguematch({
    this.leagueid,
    this.allmatch,
    this.matchlength
  });

  int? leagueid;
  int? matchlength;
  List<Matchlist>? allmatch;
}

class DateMatch {
  DateMatch({this.allmatch, this.dateTime});
  DateTime? dateTime;
  List<Matchlist>? allmatch;
}


class Countryleague {
  Country country;
  List<Allleague> allleague;
  Countryleague({required this.allleague, required this.country});
}

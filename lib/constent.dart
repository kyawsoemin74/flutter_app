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
  static const String baseUrl = "http://150.95.90.134";

  // --- UI Theme & Styling ---
  static const Color scaffoldBgColor = Color(0xFF102a4a);
  static final Color glassEffectColor = Colors.white.withOpacity(0.1);
  static final String appName = "Fover".tr;

  // --- Default Fallback Data ---
  static int defaultLeagueId = 1;
  static String defaultLeagueName = "World Cup";
  static int defaultSeason = 2022;

  // Endpoints path များရှိပါက ဒီမှာ ဆက်လက်ထည့်နိုင်သည်
  static const String matchesEndpoint = "/matches/";
  static const String matchesLiveEndpoint = "/matches/live"; // Error log အတိုင်း အမည်ပြောင်းလဲပေးထားသည်

  // Dynamic date matches အတွက် endpoint helper
  static String matchesByDateEndpoint(String date) => "/matches/$date";
  
  static const String leaguesEndpoint = "/leagues";
  static const String standingsEndpoint = "/standings"; // Standing data အတွက် endpoint အသစ်ထည့်သွင်းသည်
  static const String fixturesEndpoint = "/fixtures";
  static const String topScoresEndpoint = "/topscores";
  static const String h2hEndpoint = "/h2h";
  static const String eventsEndpoint = "/events";
  static const String adsEndpoint = "/ads";
}

// အောက်ပါ Helper function များသည် logic ပိုင်းဖြစ်သောကြောင့် 
// အပြင်မှာထားခြင်း သို့မဟုတ် Utility class တစ်ခုထဲသို့ ပြောင်းရွှေ့ခြင်းက ပိုသင့်တော်ပါသည်။

Duration ftmatchdurationdata(DateTime date) {
  DateTime today = DateTime.now();
  int secount = date.difference(today).inSeconds;

  return Duration(seconds: secount);
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
  List<Leaguematch> leaguematch = [];
  List<int> leagueid = [];
  SendPort sendPort = args[0];
  var matchlist = args[1] as List<Matchlist>;
  var status = args[2];

  for (var i = 0; i < matchlist.length; i++) {
    if (leagueid.contains(matchlist[i].league!.id) == false) {
      leagueid.add(matchlist[i].league!.id!);
    }
  }

  if (status != null) {
    for (var i = 0; i < leagueid.length; i++) {
      var data = matchlist.where((element) => element.league!.id == leagueid[i] && element.fixture!.status!.short == status).toList();
      if (data.isNotEmpty) {
        leaguematch.add(Leaguematch(leagueid: data.first.league!.id, allmatch: data));
      }
    }
  } else {
    for (var i = 0; i < leagueid.length; i++) {
      var data = matchlist.where((element) => element.league!.id! == leagueid[i]).toList();
      if (data.isNotEmpty) {
        leaguematch.add(Leaguematch(leagueid: data.first.league!.id, allmatch: data));
      }
    }
  }
  sendPort.send(leaguematch);
}

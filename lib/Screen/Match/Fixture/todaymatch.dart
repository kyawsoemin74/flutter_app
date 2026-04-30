import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/constent.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Provider/match.dart';
import '../../League/leaguedetails.dart';
import '../../Matchdetails/matchdetails.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TodayMatchPage extends StatefulWidget {
  final DateTime dateTime;
  const TodayMatchPage({Key? key, required this.dateTime}) : super(key: key);

  @override
  State<TodayMatchPage> createState() => _TodayMatchPageState();
}

class _TodayMatchPageState extends State<TodayMatchPage> {
  DateTime dateTime = DateTime.now();

  Future loaddata() async {
    await Provider.of<MatchProvider>(context, listen: false).getfixturematch(
        date: DateFormat("yyyy-MM-dd").format(DateTime(
            widget.dateTime.year, widget.dateTime.month, widget.dateTime.day)));
  }

  @override
  void initState() {
    loaddata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final livematch = Provider.of<MatchProvider>(context);
    return livematch.allfixturematchloading
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
        : matchlist();
  }

  Widget matchlist() {
    final livematch = Provider.of<MatchProvider>(context);
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            var data1 = livematch.allfixturematch[index];
            return Container(
              margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => LeaguedetailsPage(
                                leagueid: data1.allmatch!.first.leagueId ?? 0, // Use leagueId
                                season: AppConfig.defaultSeason, // Season is not in the new flat model
                                leaguename: data1.allmatch!.first.leagueName ?? "", // Use leagueName
                              )),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                      color: AppConfig.glassEffectColor,
                      ),
                      child: Text(
                        "${data1.allmatch!.first.leagueName ?? ""} - ${data1.allmatch!.first.country ?? ""}", // Use leagueName and country
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.indigoAccent),
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.h,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 0,
                        color: Colors.white.withOpacity(0.2),
                      );
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data1.allmatch!.length,
                    itemBuilder: (context, index) {
                      var data = data1.allmatch![index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                    fictureid: data.matchId ?? 0, // Use matchId
                                    team1: 0, // team ID is not in the new flat model
                                    team2: 0), // team ID is not in the new flat model
                              ));
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          color: AppConfig.glassEffectColor,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          data.homeTeam ?? "", // Use homeTeam
                                          maxLines: 1,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: Image.network(
                                          data.homeLogo ?? "", // Use homeLogo
                                          height: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    ],
                                  )),
                              if (data.status != "FT") // Use status
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          data.matchTime != null // Use matchTime
                                              ? DateFormat('hh:mm a').format(data.matchTime!)
                                              : "--:--",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          data.matchTime != null // Use matchTime
                                              ? DateFormat('dd MMM, yyyy').format(data.matchTime!)
                                              : "",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )
                                      ],
                                    )),
                              if (data.status == "FT") // Use status
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        data.score ?? "0 : 0", // Use score
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        data.status ?? "", // Use status
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12.sp),
                                      )
                                    ],
                                  ),
                                ),
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: Image.network(
                                          data.awayLogo ?? "", // Use awayLogo
                                          height: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          data.awayTeam ?? "", // Use awayTeam
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }, childCount: livematch.allfixturematch.length),
        )
      ],
    );
  }
}

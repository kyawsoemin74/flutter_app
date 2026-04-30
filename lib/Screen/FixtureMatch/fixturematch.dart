import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Provider/match.dart';
import '../../constent.dart';
import '../League/leaguedetails.dart';
import '../Matchdetails/matchdetails.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FixtureMatch extends StatefulWidget {
  const FixtureMatch({Key? key}) : super(key: key);
  @override
  State<FixtureMatch> createState() => _FixtureMatchState();
}

class _FixtureMatchState extends State<FixtureMatch> {
  @override
  void initState() {
    Provider.of<MatchProvider>(context, listen: false).gettodayfixturematch(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final livematch = Provider.of<MatchProvider>(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        var data1 = livematch.todayfixture[index];
        return Container(
          margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
          width: double.infinity,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => LeaguedetailsPage(
                            // Model အသစ်တွင် leagueId, leagueName ကို တိုက်ရိုက်သုံးသည်
                            leagueid: data1.allmatch!.first.leagueId ?? 0,
                            season: AppConfig.defaultSeason,
                            leaguename: data1.allmatch!.first.leagueName ?? "",
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
                    "${data1.allmatch!.first.leagueName ?? ""} - ${data1.allmatch!.first.country ?? ""}",
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
                    color: Colors.white.withOpacity(0.3),
                  );
                },
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data1.allmatch!.length,
                itemBuilder: (context, index) {
                  var data = data1.allmatch![index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(
                              // matchId ကိုသုံးသည်၊ team id များ model တွင် မပါသဖြင့် 0 ထားသည်
                              fictureid: data.matchId ?? 0,
                              team1: 0,
                              team2: 0),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      color: AppConfig.glassEffectColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 70.w,
                                        child: Text(
                                          data.homeTeam ?? "",
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 25.w,
                                        height: 25.h,
                                        child: Image.network(
                                          data.homeLogo ?? "",
                                          height: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        data.matchTime != null 
                                            ? DateFormat('hh:mm a').format(data.matchTime!) 
                                            : "--:--",
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        data.matchTime != null 
                                            ? DateFormat('dd MMM, yyyy').format(data.matchTime!) 
                                            : "",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )
                                    ],
                                  )),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 25.w,
                                      height: 25.h,
                                      child: Image.network(
                                        data.awayLogo ?? "",
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: 70.w,
                                      child: Text(
                                        data.awayTeam ?? "",
                                        maxLines: 1,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }, childCount: livematch.todayfixture.length),
    );
  }
}

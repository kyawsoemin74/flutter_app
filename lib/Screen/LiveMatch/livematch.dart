import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/Screen/Matchdetails/matchdetails.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Provider/match.dart';
import '../../constent.dart';
import '../League/leaguedetails.dart';

class LiveMatch extends StatefulWidget {
  const LiveMatch({Key? key}) : super(key: key);

  @override
  State<LiveMatch> createState() => _LiveMatchState();
}

class _LiveMatchState extends State<LiveMatch> {
  @override
  void initState() {
    Provider.of<MatchProvider>(context, listen: false).getlivematch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final livematch = Provider.of<MatchProvider>(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        var data1 = livematch.livematch[index];
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
                                          data.awayTeam ?? "",
                                          maxLines: 1,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 25.w,
                                        height: 25.h,
                                        child: Image.network(
                                          data.awayLogo ?? "",
                                          height: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        data.score ?? "0 - 0",
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        data.status ?? "",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
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
                                        data.homeLogo ?? "",
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
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
      }, childCount: livematch.livematch.length),
    );
    // return SliverToBoxAdapter(
    //   child: livematch.livematch.isEmpty
    //       ? Container()
    //       : SizedBox(
    //           height: 200.h,
    //           width: double.infinity,
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Container(
    //                 padding: const EdgeInsets.all(10),
    //                 child: Text(
    //                   "Live Match",
    //                   style: TextStyle(
    //                       color: Colors.white,
    //                       fontSize: 20.sp,
    //                       fontWeight: FontWeight.bold),
    //                 ),
    //               ),
    //               SizedBox(
    //                 height: 150.h,
    //                 width: double.infinity,
    //                 child: ListView.builder(
    //                   physics: const BouncingScrollPhysics(),
    //                   itemCount: livematch.livematch.length,
    //                   scrollDirection: Axis.horizontal,
    //                   itemBuilder: ((context, index) {
    //                     var data = livematch.livematch[index];
    //                     return InkWell(
    //                       onTap: () {
    //                         Navigator.push(
    //                           context,
    //                           MaterialPageRoute(
    //                             builder: (context) => DetailsPage(
    //                                 fictureid: data.fixture!.id!,
    //                                 team1: data.teams!.home['id'],
    //                                 team2: data.teams!.away['id']),
    //                           ),
    //                         );
    //                       },
    //                       child: Container(
    //                         height: 150.h,
    //                         width: 120.w,
    //                         margin: const EdgeInsets.only(left: 15),
    //                         padding: const EdgeInsets.all(10),
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(10),
    //                           color: Colors.grey[800]!.withOpacity(0.5),
    //                         ),
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Container(
    //                               padding: const EdgeInsets.symmetric(
    //                                   horizontal: 10, vertical: 5),
    //                               decoration: BoxDecoration(
    //                                   border:
    //                                       Border.all(color: Colors.red[200]!),
    //                                   borderRadius: BorderRadius.circular(50)),
    //                               child: Text(
    //                                 data.fixture!.status!.long!,
    //                                 style: TextStyle(
    //                                     fontSize: 10.sp, color: Colors.white),
    //                               ),
    //                             ),
    //                             SizedBox(height: 10.h),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 Image.network(data.teams!.away['logo'],
    //                                     height: 40),
    //                                 Image.network(data.teams!.home['logo'],
    //                                     height: 40)
    //                               ],
    //                             ),
    //                             SizedBox(height: 10.h),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 SizedBox(
    //                                     width: 80.w,
    //                                     height: 20.h,
    //                                     child: Text(
    //                                       data.teams!.away['name'],
    //                                       overflow: TextOverflow.ellipsis,
    //                                       style: const TextStyle(
    //                                           color: Colors.white),
    //                                     )),
    //                                 Text(
    //                                   data.goals!.away.toString(),
    //                                   style:
    //                                       const TextStyle(color: Colors.white),
    //                                 )
    //                               ],
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 SizedBox(
    //                                     width: 80.w,
    //                                     height: 20.h,
    //                                     child: Text(
    //                                       data.teams!.home['name'],
    //                                       overflow: TextOverflow.ellipsis,
    //                                       style: const TextStyle(
    //                                           color: Colors.white),
    //                                     )),
    //                                 Text(
    //                                   data.goals!.home.toString(),
    //                                   style:
    //                                       const TextStyle(color: Colors.white),
    //                                 )
    //                               ],
    //                             )
    //                           ],
    //                         ),
    //                       ),
    //                     );
    //                   }),
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    // );
  }
}

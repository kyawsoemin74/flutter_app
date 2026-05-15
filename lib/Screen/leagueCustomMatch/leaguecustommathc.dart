import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../Custom_Model/leaguemathc.dart';
import '../../Provider/match.dart';
import '../../constent.dart';
import '../../model/MAtchlist/matchlist.dart';
import '../Matchdetails/matchdetails.dart';

class LeagueCustomMatch extends StatefulWidget {
  final String status;
  final String data;
  const LeagueCustomMatch({Key? key, required this.status, required this.data})
      : super(key: key);

  @override
  State<LeagueCustomMatch> createState() => _LeagueCustomMatchState();
}

class _LeagueCustomMatchState extends State<LeagueCustomMatch> {
  int select = 0;
  // List<Leaguematch> custommatch = [];
  bool loading = false;
  List<Leaguematch> laguelive = [];
  List<Matchlist>? allmatch = [];

  Future getcustommatch() async {
    final livematch = Provider.of<MatchProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    await livematch.getcustomlivematch();
    laguelive.clear();
    laguelive.add(Leaguematch(
        leagueid: 0,
        allmatch: livematch.alllivematch,
        matchlength: allmatch!.length));

    laguelive.addAll(livematch.custommatch!);
    setState(() {
      loading = false;
    });
    // if (leagueid == null) {
    //   setState(() {
    //     custommatch = livematch.custommatch!;
    //   });
    // } else {
    //   setState(() {
    //     custommatch = livematch.custommatch!
    //         .where((element) => element.leagueid! == int.parse(leagueid))
    //         .toList();
    //   });
    // }
  }

  @override
  void initState() {
    getcustommatch();
    // Provider.of<MatchProvider>(context, listen: false)
    //     .getcustomlivematch(widget.data, widget.status)
    //     .then((value) => getcustommatch(leagueid: null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final livematch = Provider.of<MatchProvider>(context);

    return loading
        ? Center(child: CircularProgressIndicator())
        : livematch.custommatch!.isEmpty
            ? Container()
            : SizedBox(
                height: 200.h,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 35.h,
                      width: double.infinity,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: laguelive.length,
                          itemBuilder: ((context, index) {
                            var data = laguelive[index];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  select = index;
                                });
                                // getcustommatch(
                                //     leagueid: data.league!.id!.toString());
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.r),
                                margin: EdgeInsets.only(
                                    right: 10.w, left: index == 0 ? 10.w : 0.0),
                                decoration: BoxDecoration(
                                    color: AppConfig.glassEffectColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (index != 0)
                                      CircleAvatar( // Changed to use leagueLogo
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: NetworkImage(
                                            data.allmatch!.first.leagueLogo ?? ""),
                                        radius: 15.r,
                                      ),
                                    if (index != 0)
                                      Text(
                                        data.allmatch!.first.leagueName ?? "",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    if (index == 0)
                                      Text(
                                        "All",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          })),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 140.h,
                      width: double.infinity,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: laguelive[select].allmatch!.length,
                        itemBuilder: ((context, index) {
                          var data = laguelive[select].allmatch![index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsPage(
                                        matchId: data.matchId ?? 0),
                                  ));
                            },
                            child: Container(
                              height: 150.h,
                              width: 120.w,
                              margin: const EdgeInsets.only(left: 15),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10), // Changed to use AppConfig.glassEffectColor
                                color: AppConfig.glassEffectColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.red[200]!),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: Text(
                                      data.status ?? "", // Use status
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        height: 35.h,
                                        width: 35.h,
                                        child: Image.network( // Use homeLogo
                                            data.homeLogo ?? "",
                                            height: 40),
                                      ),
                                      SizedBox(
                                        height: 35.h,
                                        width: 35.h,
                                        child: Image.network( // Use awayLogo
                                          data.awayLogo ?? "",
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 80.w,
                                          height: 20.h,
                                          child: Text(
                                            data.homeTeam ?? "", // Use homeTeam
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                      Text(
                                        data.score?.split('-')[0].trim() ?? "0", // Extract home score from score string
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 80.w,
                                          height: 20.h,
                                          child: Text(
                                            data.awayTeam ?? "", // Use awayTeam
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                      Text(
                                        data.score?.split('-')[1].trim() ?? "0", // Extract away score from score string
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    )
                  ],
                ),
              );
  }
}

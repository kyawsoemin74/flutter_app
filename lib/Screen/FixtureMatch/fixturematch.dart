import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Provider/match.dart';
import '../../constent.dart';
import '../League/leaguedetails.dart';
import '../Matchdetails/matchdetails.dart';

class FixtureMatch extends StatefulWidget {
  const FixtureMatch({super.key});

  @override
  State<FixtureMatch> createState() => _FixtureMatchState();
}

class _FixtureMatchState extends State<FixtureMatch> {
  String _todayDate() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  @override
  void initState() {
    Provider.of<MatchProvider>(context, listen: false)
        .gettodayfixturematch(date: _todayDate());
    super.initState();
  }

  Widget _buildTeamLogo(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.sports_soccer, color: Colors.white, size: 30);
    }

    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: AppConfig.headers,
      fit: BoxFit.contain,
      width: 35.w,
      height: 35.h,
      placeholder: (context, url) => Container(
        width: 35.w,
        height: 35.h,
        alignment: Alignment.center,
        child: const Icon(Icons.sports_soccer, color: Colors.white30, size: 20),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, color: Colors.white, size: 30),
    );
  }

  Widget _buildCountryFlag(String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    final normalized = url.toLowerCase();
    if (normalized.endsWith('.svg')) {
      return SvgPicture.network(
        url,
        width: 18.w,
        height: 18.h,
        placeholderBuilder: (context) => const SizedBox.shrink(),
        fit: BoxFit.contain,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: AppConfig.headers,
      width: 18.w,
      height: 18.h,
      fit: BoxFit.contain,
      placeholder: (context, url) => const SizedBox.shrink(),
      errorWidget: (context, url, error) => const SizedBox.shrink(),
    );
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCountryFlag(data1.allmatch!.first.countryFlag),
                      if ((data1.allmatch!.first.countryFlag ?? '').isNotEmpty)
                        const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${data1.allmatch!.first.country ?? ""}${data1.allmatch!.first.country != null && data1.allmatch!.first.country!.isNotEmpty && data1.allmatch!.first.leagueName != null && data1.allmatch!.first.leagueName!.isNotEmpty ? ' - ' : ''}${data1.allmatch!.first.leagueName ?? ""}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.indigoAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.h,
                color: Colors.white.withAlpha((0.7 * 255).toInt()),
              ),
              ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0,
                    color: Colors.white.withAlpha((0.3 * 255).toInt()),
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
                              matchId: data.matchId ?? 0),
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
                                      Flexible(
                                        child: Text(
                                          data.homeTeam ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 35.w,
                                        height: 35.h,
                                        child: _buildTeamLogo(data.homeLogo),
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
                                        data.displayMatchTime,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 35.w,
                                      height: 35.h,
                                      child: _buildTeamLogo(data.awayLogo),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        data.awayTeam ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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

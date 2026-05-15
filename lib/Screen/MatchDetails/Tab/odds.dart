import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../Provider/match.dart';
import '../../../model/Odd/odd.dart';

class OddsPage extends StatefulWidget {
  final int matchId;
  const OddsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  State<OddsPage> createState() => _OddsPageState();
}

class _OddsPageState extends State<OddsPage> {
  bool loading = true;

  Future<void> loadOdds() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    await matchProvider.getOdds(matchid: widget.matchId);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadOdds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    final odds = matchProvider.odds;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (odds.isEmpty) {
      return Center(
        child: Text(
          "No data Found".tr,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      itemCount: odds.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final odd = odds[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF102a4a),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (odd.fixture != null)
                Text(
                  "Fixture ${odd.fixture!.id}".tr,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              if (odd.league != null)
                Text(
                  "League: ${odd.league!.id ?? ''}".tr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                ),
              if (odd.teams != null)
                Text(
                  "Home/Away: ${odd.teams!.home?.id ?? ''} / ${odd.teams!.away?.id ?? ''}".tr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                ),
              SizedBox(height: 10.h),
              if (odd.odds != null && odd.odds!.isNotEmpty)
                ...odd.odds!.map((element) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.name ?? "-",
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6.h),
                      if (element.values != null && element.values!.isNotEmpty)
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: element.values!.map((value) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3550),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    value.value ?? "-",
                                    style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                                  ),
                                  Text(
                                    value.odd ?? "-",
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                }).toList()
              else
                Text(
                  "Odds not available".tr,
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
            ],
          ),
        );
      },
    );
  }
}

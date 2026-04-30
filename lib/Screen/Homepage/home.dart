// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Provider/match.dart';
import '../../constent.dart';
import '../FixtureMatch/fixturematch.dart';
import '../leagueCustomMatch/leaguecustommathc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? imageurl;
  bool loading = false;
  bool isExpanded = false;

  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    Provider.of<MatchProvider>(context, listen: false).gettodayfixturematch(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppConfig.appName.tr, // Changed to use AppConfig.appName
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: LeagueCustomMatch(
                    status: 'live',
                    data: DateFormat("yyyy-MM-dd").format(DateTime.now())),
              ),
              // LiveMatch(),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Today Fixture".tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const FixtureMatch(),
            ],
          ),
        ],
      ),
    );
  }
}

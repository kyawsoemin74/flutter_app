// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Provider/match.dart';
import '../../constent.dart';
import '../FixtureMatch/fixturematch.dart';
import '../leagueCustomMatch/leaguecustommathc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? imageurl;
  bool loading = false;
  bool isExpanded = false;

  String _todayDate() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MatchProvider>(context, listen: false)
          .gettodayfixturematch(date: _todayDate());
    });
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
                    status: 'live', data: _todayDate()),
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

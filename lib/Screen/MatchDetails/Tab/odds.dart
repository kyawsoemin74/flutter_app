import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../Provider/match.dart';
import '../../../model/Odd/odd.dart';
import '../widgets/odds_row.dart';
import '../widgets/odds_section.dart';
import '../widgets/odds_threeway.dart';
import '../widgets/odds_two_option.dart';

const _backgroundColor = Colors.black;
const _dividerColor = Color(0xFF222222);

class OddsPage extends StatefulWidget {
  final int matchId;
  const OddsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  State<OddsPage> createState() => _OddsPageState();
}

class _OddsPageState extends State<OddsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MatchProvider>(context, listen: false);
      if (provider.odds.isEmpty && !provider.isLoadingOdds) {
        provider.getOdds(matchid: widget.matchId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);

    if (matchProvider.isLoadingOdds) {
      return const Center(child: CircularProgressIndicator());
    }

    if (matchProvider.oddsError != null && matchProvider.odds.isEmpty) {
      return Center(
        child: Text(
          "Unable to load odds".tr,
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
      );
    }

    final odds = matchProvider.odds;
    if (odds.isEmpty) {
      return Center(
        child: Text(
          "No odds available".tr,
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
      );
    }

    final groupedOdds = _groupOddsByMarket(odds);
    final bookmaker = odds.first.bookmaker?.trim() ?? '';
    final entries = groupedOdds.entries.toList();

    return Container(
      color: _backgroundColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        itemCount: entries.length + (bookmaker.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (bookmaker.isNotEmpty && index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookmakerHeader(bookmaker),
                SizedBox(height: 12.h),
              ],
            );
          }

          final sectionIndex = bookmaker.isNotEmpty ? index - 1 : index;
          final entry = entries[sectionIndex];
          final section = _buildMarketSection(entry.key, entry.value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              section,
              if (sectionIndex < entries.length - 1) ...[
                SizedBox(height: 12.h),
                Divider(color: _dividerColor, thickness: 1),
                SizedBox(height: 12.h),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookmakerHeader(String bookmaker) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          bookmaker,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFF222222)),
          ),
          child: Text(
            'Bookmaker'.tr,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, List<Odd>> _groupOddsByMarket(List<Odd> odds) {
    final grouped = <String, List<Odd>>{};
    for (final odd in odds) {
      final market = odd.market?.trim().isNotEmpty == true ? odd.market!.trim() : 'Other';
      grouped.putIfAbsent(market, () => []).add(odd);
    }
    return grouped;
  }

  Widget _buildMarketSection(String market, List<Odd> odds) {
    final normalized = market.toLowerCase();

    if (normalized.contains('match winner')) {
      return OddsSection(
        title: 'Who will win?',
        child: OddsThreeWay(
          options: [
            OddsThreeWayOption(
              label: '1',
              odd: _findOdd(odds, 'Home'),
              enabled: _hasSelection(odds, 'Home'),
            ),
            OddsThreeWayOption(
              label: 'X',
              odd: _findOdd(odds, 'Draw'),
              enabled: _hasSelection(odds, 'Draw'),
            ),
            OddsThreeWayOption(
              label: '2',
              odd: _findOdd(odds, 'Away'),
              enabled: _hasSelection(odds, 'Away'),
            ),
          ],
          accentColor: const Color(0xFF8A6EFF),
        ),
      );
    }

    if (normalized.contains('asian handicap')) {
      return OddsSection(
        title: 'Asian Handicap',
        child: Column(
          children: odds
              .map((odd) => Column(
                    children: [
                      OddsRow(
                        label: odd.selection ?? '-',
                        odd: odd.odd ?? '-',
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ))
              .toList(),
        ),
      );
    }

    if (normalized.contains('goals') && normalized.contains('o/u')) {
      return OddsSection(
        title: 'Goals Over/Under',
        child: Column(
          children: odds
              .map((odd) => Column(
                    children: [
                      OddsRow(
                        label: odd.selection ?? '-',
                        odd: odd.odd ?? '-',
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ))
              .toList(),
        ),
      );
    }

    if (normalized.contains('corners') && normalized.contains('o/u')) {
      return OddsSection(
        title: 'Corners Over Under',
        child: Column(
          children: odds
              .map((odd) => Column(
                    children: [
                      OddsRow(
                        label: odd.selection ?? '-',
                        odd: odd.odd ?? '-',
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ))
              .toList(),
        ),
      );
    }

    return OddsSection(
      title: market,
      child: Column(
        children: odds
            .map((odd) => Column(
                  children: [
                    OddsRow(
                      label: odd.selection ?? '-',
                      odd: odd.odd ?? '-',
                    ),
                    SizedBox(height: 4.h),
                  ],
                ))
            .toList(),
      ),
    );
  }

  String _findOdd(List<Odd> odds, String selection) {
    return odds
            .firstWhere(
              (odd) => odd.selection?.trim().toLowerCase() == selection.toLowerCase(),
              orElse: () => Odd(selection: selection, odd: '-'),
            )
            .odd ??
        '-';
  }

  bool _hasSelection(List<Odd> odds, String selection) {
    return odds.any((odd) => odd.selection?.trim().toLowerCase() == selection.toLowerCase());
  }
}

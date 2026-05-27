import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:football_xt_latest/model/Headtohead/headtohead.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;


class HeadToHeadPage extends StatefulWidget {
  const HeadToHeadPage({Key? key}) : super(key: key);

  @override
  State<HeadToHeadPage> createState() => _HeadToHeadPageState();
}

class _HeadToHeadPageState extends State<HeadToHeadPage> {
  Future<void> _loadH2HIfNeeded() async {
    final match = Provider.of<MatchProvider>(context, listen: false);
    final matchId = match.singleMatchData?.matchId;
    if (match.h2h.isEmpty && matchId != null && !match.isLoadingH2H) {
      await match.geth2h(matchid: matchId);
    }
  }

  InterstitialAd? _interstitialAd;
  fb.InterstitialAd? _fbinterstitialAd;
  int _numInterstitialLoadAttempts = 0;
  Future _createInterstitialAd() async {
     final provider = Provider.of<Adsprovider>(context, listen: false);
    InterstitialAd.load(
      adUnitId: provider.ads!.gInterstitial!,
      request: const AdRequest(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (kDebugMode) {
            print('$ad loaded');
          }
          ad.show();
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;

          _createInterstitialAd();
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('Warning: attempt to show interstitial before loaded.');
      }
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('ad onAdShowedFullScreenContent.');
        }
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('$ad onAdDismissedFullScreenContent.');
        }
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  bool _fbisInterstitialAdLoaded = false;
  Future loadfbInterstitialAd() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final interstitialAd = fb.InterstitialAd(provider.ads!.fbInterstitial!);
    interstitialAd.listener = fb.InterstitialAdListener(
      onLoaded: () {
        print('interstitial ad loaded');
        _fbisInterstitialAdLoaded = true;
      },
      onError: (code, message) {
        print('interstitial ad error\ncode = $code\nmessage = $message');
      },
      onDismissed: () {
        interstitialAd.destroy();
        loadfbInterstitialAd();
      },
    );
    interstitialAd.load();
    _fbinterstitialAd = interstitialAd;
  }

  showfbInterstitialAd() {
    if (_fbisInterstitialAdLoaded == true) {
      _fbinterstitialAd!.show();
    } else if (kDebugMode) {
      print("Interstial Ad not yet loaded!");
    }
  }

  bool clickads() {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final box = Hive.isBoxOpen('ads') ? Hive.box('ads') : null;
    final clickads = box?.get('click') ?? 0;
    if (clickads % provider.ads!.adsClick! == 0) {
      if (kDebugMode) {
        print(true);
      }
      box?.put('click', clickads + 1);
      return true;
    } else {
      if (kDebugMode) {
        print(false);
      }
      box?.put('click', clickads + 1);
      return false;
    }
  }

  Future loadinterstitialads() async {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    if (provider.ads!.google == 1 && clickads() == true) {
      _createInterstitialAd();
    } else if (provider.ads!.fb == 1 && clickads() == true) {
      loadfbInterstitialAd().then((value) =>
          Future.delayed(Duration(seconds: 5), () => showfbInterstitialAd()));
    }
  }
  @override
  void initState() {
    super.initState();
    loadinterstitialads();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadH2HIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchProvider>(context);
    final h2h = match.h2h;

    if (match.isLoadingH2H) {
      return _buildLoading();
    }

    if (match.h2hError != null && h2h.isEmpty) {
      return _buildErrorState(match);
    }

    if (h2h.isEmpty) {
      return _buildEmptyState();
    }

    final summary = _computeSummary(h2h);
    final recentMatches = h2h.take(10).toList();

    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('H2H Summary'.tr),
            const SizedBox(height: 10),
            _buildSummaryRow(summary),
            const SizedBox(height: 12),
            _buildSectionTitle('Recent Meetings'.tr),
            const SizedBox(height: 10),
            _buildRecentMatches(recentMatches, summary.teamAName, summary.teamBName),
            const SizedBox(height: 12),
            _buildSectionTitle('Goal Statistics'.tr),
            const SizedBox(height: 10),
            _buildGoalStats(summary),
            const SizedBox(height: 12),
            _buildSectionTitle('Form Comparison'.tr),
            const SizedBox(height: 10),
            _buildComparisonSection(summary),
            if (summary.homeMatches > 0 || summary.awayMatches > 0) ...[
              const SizedBox(height: 12),
              _buildSectionTitle('Venue Comparison'.tr),
              const SizedBox(height: 10),
              _buildVenueComparison(summary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(5, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == 4 ? 0 : 10.0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(MatchProvider match) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            match.h2hError?.tr ?? 'Unable to load H2H data'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white12,
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final matchId = match.singleMatchData?.matchId;
              if (matchId != null) {
                match.geth2h(matchid: matchId);
              }
            },
            child: Text(
              'Retry'.tr,
              style: TextStyle(fontSize: 13.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 34, color: Colors.white24),
          const SizedBox(height: 10),
          Text(
            'No H2H history available'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white),
    );
  }

  Widget _buildSummaryRow(_H2HSummary summary) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSummaryCard(summary.teamAName, summary.teamAWins.toString()),
        _buildSummaryCard('Draw'.tr, summary.draws.toString()),
        _buildSummaryCard(summary.teamBName, summary.teamBWins.toString()),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      constraints: const BoxConstraints(minWidth: 96, maxWidth: 156),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildRecentMatches(List<HeadtoHead> matches, String teamA, String teamB) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      separatorBuilder: (context, index) => Column(
        children: const [
          SizedBox(height: 8),
          Divider(color: Colors.white12, height: 1),
          SizedBox(height: 8),
        ],
      ),
      itemBuilder: (context, index) {
        final item = matches[index];
        final homeTeam = _teamMap(item.teams?.home);
        final awayTeam = _teamMap(item.teams?.away);
        final homeGoals = _intValue(item.goals?.home);
        final awayGoals = _intValue(item.goals?.away);
        final isDraw = homeGoals == awayGoals;
        final homeName = _stringValue(homeTeam?['name']) ?? teamA;
        final awayName = _stringValue(awayTeam?['name']) ?? teamB;
        final homeLogo = _stringValue(homeTeam?['logo']);
        final awayLogo = _stringValue(awayTeam?['logo']);
        final matchDate = _formatDate(item.fixture?.date);
        final leagueName = item.league?.name ?? '';
        final homeWinner = !isDraw && homeGoals > awayGoals;
        final awayWinner = !isDraw && awayGoals > homeGoals;

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1318),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildTeamRow(homeName, homeLogo, homeWinner),
                  Expanded(
                    child: Text(
                      '$homeGoals - $awayGoals',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  _buildTeamRow(awayName, awayLogo, awayWinner, isTrailing: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      leagueName,
                      style: TextStyle(fontSize: 11.sp, color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    matchDate,
                    style: TextStyle(fontSize: 11.sp, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamRow(String name, String? logo, bool highlight, {bool isTrailing = false}) {
    final text = Text(
      name,
      textAlign: isTrailing ? TextAlign.right : TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: highlight ? const Color(0xFF90EE90) : Colors.white,
      ),
    );
    final avatar = Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: logo != null && logo.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logo,
                fit: BoxFit.cover,
                width: 24,
                height: 24,
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, size: 16, color: Colors.white24),
              )
            : const Icon(Icons.sports_soccer, size: 16, color: Colors.white24),
      ),
    );

    return Expanded(
      child: Row(
        mainAxisAlignment: isTrailing ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: isTrailing ? [text, const SizedBox(width: 8), avatar] : [avatar, const SizedBox(width: 8), Expanded(child: text)],
      ),
    );
  }

  Widget _buildGoalStats(_H2HSummary summary) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip('Avg Goals'.tr, summary.averageGoals.toStringAsFixed(1)),
        _buildStatChip('BTTS'.tr, '${summary.bttsPercent.toStringAsFixed(0)}%'),
        _buildStatChip('Over 2.5'.tr, '${summary.over25Percent.toStringAsFixed(0)}%'),
        _buildStatChip('Clean sheets'.tr, '${summary.cleanSheets}'),
      ],
    );
  }

  Widget _buildStatChip(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11.sp, color: Colors.white54)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(_H2HSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildComparisonRow('Wins'.tr, summary.teamAWins, summary.teamBWins, summary),
        const SizedBox(height: 10),
        _buildComparisonRow('Goals'.tr, summary.teamAGoals, summary.teamBGoals, summary),
        const SizedBox(height: 10),
        _buildComparisonRow('Clean sheets'.tr, summary.teamACleanSheets, summary.teamBCleanSheets, summary),
        const SizedBox(height: 10),
        _buildComparisonRow('Scoring rate'.tr, summary.teamAScoringRate, summary.teamBScoringRate, summary, isPercentage: true),
      ],
    );
  }

  Widget _buildComparisonRow(String title, int aValue, int bValue, _H2HSummary summary, {bool isPercentage = false}) {
    final maxValue = math.max(aValue, bValue).toDouble();
    final scale = maxValue > 0 ? maxValue : 1.0;
    final aFraction = (aValue / scale).clamp(0.0, 1.0);
    final bFraction = (bValue / scale).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.white70))),
            Text(
              isPercentage ? '${aValue}% / ${bValue}%' : '$aValue / $bValue',
              style: TextStyle(fontSize: 12.sp, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildProgressBar(summary.teamAName, aFraction, Colors.lightBlueAccent),
        const SizedBox(height: 6),
        _buildProgressBar(summary.teamBName, bFraction, Colors.greenAccent),
      ],
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.white60)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueComparison(_H2HSummary summary) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip('Home H2H'.tr, summary.homeMatches.toString()),
        _buildStatChip('Away H2H'.tr, summary.awayMatches.toString()),
      ],
    );
  }

  _H2HSummary _computeSummary(List<HeadtoHead> matches) {
    final first = matches.first;
    final teamAName = _stringValue(_teamMap(first.teams?.home)?['name']) ?? 'Team A'.tr;
    final teamBName = _stringValue(_teamMap(first.teams?.away)?['name']) ?? 'Team B'.tr;

    var teamAWins = 0;
    var teamBWins = 0;
    var draws = 0;
    var totalGoals = 0;
    var btts = 0;
    var over25 = 0;
    var cleanSheets = 0;
    var teamAGoals = 0;
    var teamBGoals = 0;
    var teamACleanSheets = 0;
    var teamBCleanSheets = 0;
    var teamAScoringMatches = 0;
    var teamBScoringMatches = 0;
    var homeMatches = 0;
    var awayMatches = 0;

    for (final item in matches) {
      final homeName = _stringValue(_teamMap(item.teams?.home)?['name']) ?? teamAName;
      final awayName = _stringValue(_teamMap(item.teams?.away)?['name']) ?? teamBName;
      final homeGoals = _intValue(item.goals?.home);
      final awayGoals = _intValue(item.goals?.away);
      final total = homeGoals + awayGoals;
      totalGoals += total;

      final teamAHome = homeName.toLowerCase() == teamAName.toLowerCase();
      final teamAGoalCount = teamAHome ? homeGoals : awayGoals;
      final teamBGoalCount = teamAHome ? awayGoals : homeGoals;
      teamAGoals += teamAGoalCount;
      teamBGoals += teamBGoalCount;

      if (teamAGoalCount > 0) teamAScoringMatches++;
      if (teamBGoalCount > 0) teamBScoringMatches++;

      if (homeGoals == 0 || awayGoals == 0) {
        cleanSheets++;
        if (homeGoals == 0) {
          if (awayName.toLowerCase() == teamAName.toLowerCase()) {
            teamACleanSheets++;
          } else {
            teamBCleanSheets++;
          }
        }
        if (awayGoals == 0) {
          if (homeName.toLowerCase() == teamAName.toLowerCase()) {
            teamACleanSheets++;
          } else {
            teamBCleanSheets++;
          }
        }
      }

      if (homeGoals > awayGoals) {
        if (homeName.toLowerCase() == teamAName.toLowerCase()) {
          teamAWins++;
        } else {
          teamBWins++;
        }
      } else if (awayGoals > homeGoals) {
        if (awayName.toLowerCase() == teamAName.toLowerCase()) {
          teamAWins++;
        } else {
          teamBWins++;
        }
      } else {
        draws++;
      }

      if (homeGoals > 0 && awayGoals > 0) {
        btts++;
      }
      if (total > 2) {
        over25++;
      }
      if (homeName.toLowerCase() == teamAName.toLowerCase()) {
        homeMatches++;
      } else if (homeName.toLowerCase() == teamBName.toLowerCase()) {
        awayMatches++;
      }
    }

    final matchCount = matches.length;
    final averageGoals = matchCount > 0 ? totalGoals / matchCount : 0.0;
    final bttsPercent = matchCount > 0 ? (btts * 100 / matchCount) : 0.0;
    final over25Percent = matchCount > 0 ? (over25 * 100 / matchCount) : 0.0;
    final teamAScoringRate = matchCount > 0 ? ((teamAScoringMatches * 100) / matchCount).round() : 0;
    final teamBScoringRate = matchCount > 0 ? ((teamBScoringMatches * 100) / matchCount).round() : 0;

    return _H2HSummary(
      teamAName: teamAName,
      teamBName: teamBName,
      teamAWins: teamAWins,
      teamBWins: teamBWins,
      draws: draws,
      averageGoals: averageGoals,
      bttsPercent: bttsPercent,
      over25Percent: over25Percent,
      cleanSheets: cleanSheets,
      teamAGoals: teamAGoals,
      teamBGoals: teamBGoals,
      teamACleanSheets: teamACleanSheets,
      teamBCleanSheets: teamBCleanSheets,
      teamAScoringRate: teamAScoringRate,
      teamBScoringRate: teamBScoringRate,
      homeMatches: homeMatches,
      awayMatches: awayMatches,
    );
  }

  Map<String, dynamic>? _teamMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  int _intValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    return '${value.day.toString().padLeft(2, '0')} ${_monthShort(value.month)} ${value.year}';
  }

  String _monthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }
}

class _H2HSummary {
  final String teamAName;
  final String teamBName;
  final int teamAWins;
  final int teamBWins;
  final int draws;
  final double averageGoals;
  final double bttsPercent;
  final double over25Percent;
  final int cleanSheets;
  final int teamAGoals;
  final int teamBGoals;
  final int teamACleanSheets;
  final int teamBCleanSheets;
  final int teamAScoringRate;
  final int teamBScoringRate;
  final int homeMatches;
  final int awayMatches;

  _H2HSummary({
    required this.teamAName,
    required this.teamBName,
    required this.teamAWins,
    required this.teamBWins,
    required this.draws,
    required this.averageGoals,
    required this.bttsPercent,
    required this.over25Percent,
    required this.cleanSheets,
    required this.teamAGoals,
    required this.teamBGoals,
    required this.teamACleanSheets,
    required this.teamBCleanSheets,
    required this.teamAScoringRate,
    required this.teamBScoringRate,
    required this.homeMatches,
    required this.awayMatches,
  });
}

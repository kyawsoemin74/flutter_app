import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../../Provider/Ads/ads.dart';
import '../../../Provider/match.dart';
import '../../../model/SingleFixture/singlefixture.dart';
import 'package:football_xt_latest/easy_audience_network_stub.dart' as fb;


// ignore: library_private_types_in_public_api
class LineUpPage extends StatefulWidget {
  const LineUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LineUpPageState createState() => _LineUpPageState();
}

class _LineUpPageState extends State<LineUpPage> {
  InterstitialAd? _interstitialAd;
  fb.InterstitialAd? _fbinterstitialAd;
  // ignore: unused_field
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
            debugPrint('$ad loaded');
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
        debugPrint('Warning: attempt to show interstitial before loaded.');
      }
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          debugPrint('ad onAdShowedFullScreenContent.');
        }
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          debugPrint('$ad onAdDismissedFullScreenContent.');
        }
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
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
        debugPrint('interstitial ad loaded');
        _fbisInterstitialAdLoaded = true;
      },
      onError: (code, message) {
        debugPrint('interstitial ad error\ncode = $code\nmessage = $message');
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
      debugPrint("Interstial Ad not yet loaded!");
    }
  }

  bool clickads() {
    final provider = Provider.of<Adsprovider>(context, listen: false);
    final box = Hive.isBoxOpen('ads') ? Hive.box('ads') : null;
    final clickads = box?.get('click') ?? 0;
    if (clickads % provider.ads!.adsClick! == 0) {
      if (kDebugMode) {
        debugPrint(true.toString());
      }
      box?.put('click', clickads + 1);
      return true;
    } else {
      if (kDebugMode) {
        debugPrint(false.toString());
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
      final match = Provider.of<MatchProvider>(context, listen: false);
      final matchId = match.singleMatchData?.matchId;
      debugPrint('LINEUP TAB OPENED: initState matchId=$matchId');
      if (match.lineups.isEmpty && matchId != null) {
        match.getMatchLineup(matchid: matchId);
      }
    });
  }

  bool _formationExpanded = true;
  bool _benchExpanded = false;
  bool _coachExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, match, child) {
        if (match.isLoadingLineup) {
          return _buildLoading();
        }

        if (match.lineupError != null && match.lineups.isEmpty) {
          return _buildErrorState(match);
        }

        if (match.lineupUnavailable && match.lineups.isEmpty) {
          return _buildNoLineupState();
        }

        final List<Lineups> lineups = match.lineups.isNotEmpty ? match.lineups : <Lineups>[];

        if (lineups.isEmpty) {
          return _buildNoDataState();
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(
                  title: "Formation".tr,
                  expanded: _formationExpanded,
                  onTap: () => setState(() => _formationExpanded = !_formationExpanded),
                ),
                if (_formationExpanded) ...[
                  const SizedBox(height: 10),
                  _buildFormationSection(lineups),
                ],
                const SizedBox(height: 16),
                _buildSectionHeader(
                  title: "Bench".tr,
                  expanded: _benchExpanded,
                  onTap: () => setState(() => _benchExpanded = !_benchExpanded),
                ),
                if (_benchExpanded) ...[
                  const SizedBox(height: 10),
                  _buildBenchSection(lineups),
                ],
                const SizedBox(height: 16),
                _buildSectionHeader(
                  title: "Coach".tr,
                  expanded: _coachExpanded,
                  onTap: () => setState(() => _coachExpanded = !_coachExpanded),
                ),
                if (_coachExpanded) ...[
                  const SizedBox(height: 10),
                  _buildCoachSection(lineups),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({required String title, required bool expanded, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              height: index == 0 ? 18 : 44,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(MatchProvider match) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              match.lineupError!.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final matchId = match.singleMatchData?.matchId;
                if (matchId != null) {
                  match.getMatchLineup(matchid: matchId);
                }
              },
              child: Text('Retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLineupState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          "Lineups will be available closer to kickoff".tr,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Text(
        "No data Found".tr,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
    );
  }

  Widget _buildFormationSection(List<Lineups> lineups) {
    return LayoutBuilder(builder: (context, constraints) {
      final showSideBySide = constraints.maxWidth > 760 && lineups.length > 1;
      return showSideBySide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTeamFormationCard(lineups[0], true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTeamFormationCard(lineups[1], false)),
              ],
            )
          : Column(
              children: [
                _buildTeamFormationCard(lineups[0], true),
                if (lineups.length > 1) ...[
                  const SizedBox(height: 12),
                  _buildTeamFormationCard(lineups[1], false),
                ],
              ],
            );
    });
  }

  Widget _buildTeamFormationCard(Lineups team, bool alignLeft) {
    final sideLabel = _getTeamSideLabel(team);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10151E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.team?.name ?? '-'.tr,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        if (sideLabel.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(118, 255, 3, 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sideLabel,
                              style: TextStyle(fontSize: 11.sp, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      team.formation ?? '-'.tr,
                      style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                team.coach?.name ?? "Coach".tr,
                style: TextStyle(fontSize: 12.sp, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPitch(team),
        ],
      ),
    );
  }

  Widget _buildPitch(Lineups team) {
    final formation = team.formation ?? '';
    final rows = _buildFormationRows(formation);
    final playerSlots = _assignPlayersToSlots(team.startXi ?? <StartXi>[], rows);

    return AspectRatio(
      aspectRatio: 0.78,
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            _buildPitchBackground(),
            for (var rowIndex = 0; rowIndex < playerSlots.length; rowIndex++)
              for (var slotIndex = 0; slotIndex < playerSlots[rowIndex].length; slotIndex++)
                Positioned(
                  left: _slotLeft(
                    slotIndex,
                    playerSlots[rowIndex].length,
                    constraints.maxWidth,
                    _slotWidth(playerSlots[rowIndex].length, constraints.maxWidth),
                  ),
                  top: _slotTop(rowIndex, playerSlots.length, constraints.maxHeight),
                  width: _slotWidth(playerSlots[rowIndex].length, constraints.maxWidth),
                  child: _PitchPlayerWidget(
                    slot: playerSlots[rowIndex][slotIndex],
                    size: _slotWidth(playerSlots[rowIndex].length, constraints.maxWidth),
                  ),
                ),
          ],
        );
      }),
    );
  }

  Widget _buildPitchBackground() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: CustomPaint(
                painter: _PitchPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<List<_Slot>> _buildFormationRows(String formation) {
    final structure = formation
        .split('-')
        .map((token) => int.tryParse(token.trim()) ?? 0)
        .where((count) => count > 0)
        .toList();

    if (structure.isEmpty) {
      return [
        [
          _Slot('GK', null),
        ]
      ];
    }

    final rows = <List<_Slot>>[];
    final reversed = structure.reversed.toList();

    for (var i = 0; i < reversed.length; i++) {
      rows.add(_slotsForRow(reversed[i], i == 0, i == reversed.length - 1));
    }
    rows.add([_Slot('GK', null)]);
    return rows;
  }

  List<_Slot> _slotsForRow(int count, bool isForwardRow, bool isDefenseRow) {
    if (count == 1) {
      return [
        _Slot(isDefenseRow ? 'CB' : isForwardRow ? 'ST' : 'CM', null),
      ];
    }
    if (count == 2) {
      return [
        _Slot(isDefenseRow ? 'LB' : isForwardRow ? 'LW' : 'LM', null),
        _Slot(isDefenseRow ? 'RB' : isForwardRow ? 'RW' : 'RM', null),
      ];
    }
    if (count == 3) {
      return [
        _Slot(isDefenseRow ? 'LB' : 'LW', null),
        _Slot(isDefenseRow ? 'CB' : isForwardRow ? 'ST' : 'CM', null),
        _Slot(isDefenseRow ? 'RB' : 'RW', null),
      ];
    }
    if (count == 4) {
      return [
        _Slot(isDefenseRow ? 'LB' : 'LW', null),
        _Slot(isDefenseRow ? 'LCB' : isForwardRow ? 'LM' : 'LCM', null),
        _Slot(isDefenseRow ? 'RCB' : isForwardRow ? 'RM' : 'RCM', null),
        _Slot(isDefenseRow ? 'RB' : 'RW', null),
      ];
    }
    if (count == 5) {
      return [
        _Slot('LW', null),
        _Slot('LCM', null),
        _Slot('CAM', null),
        _Slot('RCM', null),
        _Slot('RW', null),
      ];
    }
    return List.generate(count, (index) => _Slot('M', null));
  }

  List<List<_Slot>> _assignPlayersToSlots(List<StartXi> players, List<List<_Slot>> rows) {
    final assigned = rows.map((row) => row.map((slot) => _Slot(slot.key, null)).toList()).toList();
    final unassigned = <StartXi>[];

    for (final player in players) {
      if (player.player == null) continue;
      final pos = player.player!.pos?.toUpperCase() ?? '';
      var matched = false;

      for (var rowIndex = 0; rowIndex < assigned.length; rowIndex++) {
        final isDefenseRow = rowIndex == assigned.length - 1;
        final isForwardRow = rowIndex == 0;
        for (var slotIndex = 0; slotIndex < assigned[rowIndex].length; slotIndex++) {
          final slot = assigned[rowIndex][slotIndex];
          if (slot.player != null) continue;
          final key = slot.key.toUpperCase();
          if (_positionMatchesSlot(pos, key, isDefenseRow, isForwardRow)) {
            assigned[rowIndex][slotIndex] = _Slot(slot.key, player);
            matched = true;
            break;
          }
          if (key == 'M' && pos.contains('M')) {
            assigned[rowIndex][slotIndex] = _Slot(slot.key, player);
            matched = true;
            break;
          }
        }
        if (matched) break;
      }
      if (!matched) {
        unassigned.add(player);
      }
    }

    var unassignedIndex = 0;
    for (var rowIndex = 0; rowIndex < assigned.length; rowIndex++) {
      for (var slotIndex = 0; slotIndex < assigned[rowIndex].length; slotIndex++) {
        if (assigned[rowIndex][slotIndex].player == null && unassignedIndex < unassigned.length) {
          assigned[rowIndex][slotIndex] = _Slot(assigned[rowIndex][slotIndex].key, unassigned[unassignedIndex]);
          unassignedIndex++;
        }
      }
    }

    return assigned;
  }

  bool _positionMatchesSlot(String pos, String slotKey, bool isDefenseRow, bool isForwardRow) {
    if (pos == slotKey) return true;
    if (pos.contains('GK') && slotKey == 'GK') return true;
    if ((pos.contains('DF') || pos.contains('DEF') || pos.contains('CB') || pos.contains('LB') || pos.contains('RB') || pos.contains('WB')) &&
        (slotKey.contains('B') || slotKey.contains('LB') || slotKey.contains('RB') || slotKey.contains('CB'))) {
      return true;
    }
    if ((pos.contains('MF') || pos.contains('MID') || pos.contains('CM') || pos.contains('LM') || pos.contains('RM') || pos.contains('CAM')) &&
        slotKey.contains('M')) {
      return true;
    }
    if ((pos.contains('FW') || pos.contains('ATT') || pos.contains('ST') || pos.contains('LW') || pos.contains('RW')) &&
        (slotKey.contains('W') || slotKey.contains('ST') || slotKey == 'F')) {
      return true;
    }
    return slotKey.contains(pos) || pos.contains(slotKey);
  }

  double _slotWidth(int count, double width) {
    final maxSlot = 92.0;
    final available = math.max(width - 24, 0.0);
    final computed = available / math.max(count, 1);
    return math.max(56.0, math.min(maxSlot, computed));
  }

  double _slotLeft(int slotIndex, int count, double width, double slotWidth) {
    final gap = math.max(4.0, (width - slotWidth * count) / (count + 1));
    return gap * (slotIndex + 1) + slotWidth * slotIndex;
  }

  double _slotTop(int rowIndex, int rowCount, double height) {
    final baseTop = height * ((rowIndex + 1) / (rowCount + 1));
    return math.min(math.max(baseTop - 26, 12.0), height - 72);
  }

  String _getTeamSideLabel(Lineups team) {
    final matchData = Provider.of<MatchProvider>(context, listen: false).singleMatchData;
    final homeName = matchData?.homeTeam?.toLowerCase().trim();
    final awayName = matchData?.awayTeam?.toLowerCase().trim();
    final teamName = team.team?.name?.toLowerCase().trim();

    if (teamName != null && homeName != null && teamName == homeName) {
      return 'Home'.tr;
    }
    if (teamName != null && awayName != null && teamName == awayName) {
      return 'Away'.tr;
    }
    return '';
  }

  Widget _buildBenchSection(List<Lineups> lineups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < lineups.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lineups[index].team?.name ?? '-'.tr,
                  style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: lineups[index].substitutes?.length ?? 0,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, subIndex) {
                      final player = lineups[index].substitutes![subIndex].player;
                      return _buildBenchChip(player);
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBenchChip(StartXiPlayer? player) {
    final name = player?.name ?? '-'.tr;
    final number = player?.number?.toString() ?? '-';
    return Container(
      constraints: const BoxConstraints(minWidth: 52, maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2734),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: TextStyle(fontSize: 11.sp, color: Colors.white70),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 11.sp, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachSection(List<Lineups> lineups) {
    return Column(
      children: [
        for (final lineup in lineups)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B242F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lineup.team?.name ?? '-'.tr,
                  style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                ),
                Text(
                  lineup.coach?.name ?? '-'.tr,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PitchPlayerWidget extends StatelessWidget {
  final _Slot? slot;
  final double size;

  const _PitchPlayerWidget({this.slot, this.size = 92});

  @override
  Widget build(BuildContext context) {
    if (slot == null || slot!.player == null) {
      return const SizedBox.shrink();
    }

    final startXi = slot!.player!;
    final player = startXi.player!;
    final ratingText = player.rating != null ? player.rating!.toStringAsFixed(1) : '';
    final numberText = player.number?.toString() ?? '';
    final badges = _buildBadges(player);
    final avatarSize = math.max(40.0, math.min(size * 0.55, 52.0));
    final containerSize = avatarSize + 18;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: const Color(0xFF17212D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: ClipOval(
                  child: player.photo != null && player.photo!.isNotEmpty &&
                          Uri.tryParse(player.photo!)?.hasAbsolutePath == true
                      ? CachedNetworkImage(
                          imageUrl: player.photo!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white10),
                          errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white38),
                        )
                      : const Icon(Icons.person, color: Colors.white38),
                ),
              ),
            ),
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  numberText,
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
              ),
            ),
            if (ratingText.isNotEmpty)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC700),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ratingText,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            if (badges.isNotEmpty)
              Positioned(
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: badges,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: math.max(64.0, size - 4),
          child: Text(
            player.name ?? '-'.tr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBadges(StartXiPlayer player) {
    final badges = <Widget>[];
    if (player.captain == true) {
      badges.add(const Text('(C)', style: TextStyle(fontSize: 10, color: Colors.white)));
    }
    if (player.yellowCard == true) {
      badges.add(const Text('🟨', style: TextStyle(fontSize: 10)));
    }
    if (player.redCard == true) {
      badges.add(const Text('🟥', style: TextStyle(fontSize: 10)));
    }
    if (player.goal == true) {
      badges.add(const Text('⚽', style: TextStyle(fontSize: 10)));
    }
    if (player.substitute == true) {
      badges.add(const Text('↩', style: TextStyle(fontSize: 10)));
    }
    if (player.injured == true) {
      badges.add(const Text('✚', style: TextStyle(fontSize: 10, color: Colors.redAccent)));
    }
    return badges;
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)), paint);

    final middle = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawCircle(middle, size.width * 0.12, paint);
    canvas.drawCircle(middle, size.width * 0.02, paint);

    final penaltyWidth = size.width * 0.28;
    final penaltyHeight = size.height * 0.14;
    final topPenalty = Rect.fromLTWH((size.width - penaltyWidth) / 2, 0, penaltyWidth, penaltyHeight);
    final bottomPenalty = Rect.fromLTWH((size.width - penaltyWidth) / 2, size.height - penaltyHeight, penaltyWidth, penaltyHeight);
    canvas.drawRect(topPenalty, paint);
    canvas.drawRect(bottomPenalty, paint);

    final centerLine = Paint()..color = Colors.white10..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), centerLine);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), centerLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Slot {
  final String key;
  final StartXi? player;

  _Slot(this.key, this.player);
}

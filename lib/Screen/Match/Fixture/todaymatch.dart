import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:football_xt_latest/constent.dart';
import 'package:provider/provider.dart';
import '../../../Provider/match.dart';
import '../../Matchdetails/matchdetails.dart';
import '../../../model/All_League/all_league.dart';
import '../../../model/MAtchlist/matchlist.dart';
import '../../../utils/country_flag_helper.dart';

// Constants for reusability and maintainability
const double kTeamLogoSize = 20.0;
const double kCountryFlagSize = 20.0;
const double kMatchStateWidth = 28.0;
const double kMatchStateFont = 13.0;
const double kScoreBoxWidth = 50.0;
const double kNotificationWidth = 16.0;
const double kItemHorizontalPadding = 10.0;
const double kGap = 3.0;
const double kLeagueTileMargin = 8.0;
const double kLeagueTileBorderRadius = 12.0;
const Duration kFadeInDuration = Duration(milliseconds: 200);
const Duration kRotationDuration = Duration(milliseconds: 200);

enum MatchState { scheduled, live, finished }

// Optimized team logo builder with better caching
Widget _buildTeamLogo(String? url) {
  if (url == null || url.isEmpty) {
    return const Icon(Icons.sports_soccer, color: Colors.white, size: 30);
  }
  return CachedNetworkImage(
    imageUrl: url,
    httpHeaders: AppConfig.headers,
    fit: BoxFit.contain,
    width: kTeamLogoSize,
    height: kTeamLogoSize,
    memCacheWidth: kTeamLogoSize.toInt(),
    memCacheHeight: kTeamLogoSize.toInt(),
    maxWidthDiskCache: (kTeamLogoSize * 2).toInt(),
    maxHeightDiskCache: (kTeamLogoSize * 2).toInt(),
    fadeInDuration: kFadeInDuration,
    placeholder: (context, url) => Container(
      width: kTeamLogoSize,
      height: kTeamLogoSize,
      alignment: Alignment.center,
      child: const Icon(Icons.sports_soccer, color: Colors.white30, size: 20),
    ),
    errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, color: Colors.white, size: 30),
  );
}

class TodayMatchPage extends StatefulWidget {
  final DateTime dateTime;
  const TodayMatchPage({super.key, required this.dateTime});

  @override
  State<TodayMatchPage> createState() => _TodayMatchPageState();
}

class _TodayMatchPageState extends State<TodayMatchPage> {
  Future<void> loaddata() async {
    final selectedDate = DateTime(widget.dateTime.year, widget.dateTime.month, widget.dateTime.day);
    final dateString = selectedDate.toIso8601String().split('T').first;
    final provider = Provider.of<MatchProvider>(context, listen: false);

    if (provider.lastFixtureDate == dateString && provider.groupedAllFixtureMatches.isNotEmpty) {
      return;
    }

    await provider.getfixturematch(date: dateString);
  }

  @override
  void initState() {
    super.initState();
    loaddata();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MatchProvider, (bool, List<LeagueGroup>)>(
      selector: (context, provider) => (provider.allfixturematchloading, provider.groupedAllFixtureMatches),
      builder: (context, data, child) {
        final loading = data.$1;
        final groups = data.$2;

        if (loading && groups.isEmpty) {
          return const TodayMatchSkeleton();
        }

        if (groups.isEmpty) {
          return const Center(
            child: Text(
              'No Matches Found',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        return GroupedMatchList(groups: groups);
      },
    );
  }
}

class TodayMatchSkeleton extends StatelessWidget {
  const TodayMatchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: List.generate(
        3,
        (index) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SkeletonBox(width: 140, height: 16),
                      const SizedBox(height: 10),
                      const SkeletonBox(width: 90, height: 12),
                    ],
                  ),
                ),
                Column(
                  children: List.generate(
                    2,
                    (matchIndex) => Container(
                      margin: EdgeInsets.only(bottom: matchIndex == 1 ? 0 : 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonBox(width: 80, height: 12),
                                SizedBox(height: 8),
                                SkeletonBox(width: 90, height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              SkeletonBox(width: 42, height: 22),
                              SizedBox(height: 8),
                              SkeletonBox(width: 30, height: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class GroupedMatchList extends StatelessWidget {
  final List<LeagueGroup> groups;

  const GroupedMatchList({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => LeagueGroupTile(group: groups[index]),
              childCount: groups.length,
            ),
          ),
        ],
      ),
    );
  }
}

class LeagueGroupTile extends StatefulWidget {
  final LeagueGroup group;

  const LeagueGroupTile({super.key, required this.group});

  @override
  State<LeagueGroupTile> createState() => _LeagueGroupTileState();
}

class _LeagueGroupTileState extends State<LeagueGroupTile> {
  late bool _expanded = widget.group.isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kLeagueTileMargin, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(kLeagueTileBorderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kLeagueTileBorderRadius),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey(widget.group.league.id ?? widget.group.league.name),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            initiallyExpanded: _expanded,
            onExpansionChanged: (value) {
              setState(() {
                _expanded = value;
                widget.group.isExpanded = value;
              });
            },
            title: LeagueHeaderWidget(
              league: widget.group.league,
              country: widget.group.country,
              countryFlag: widget.group.countryFlag,
              matchCount: widget.group.matches.length,
            ),
            trailing: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _expanded ? 0.5 : 0,
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
            ),
            children: _buildMatchChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMatchChildren() {
    if (widget.group.matches.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(
            'No matches available for this league.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ];
    }

    final children = <Widget>[];
    
    // Add subtle divider between header and matches
    children.add(const Divider(color: Colors.white10, height: 1));
    
    for (var i = 0; i < widget.group.matches.length; i++) {
      final match = widget.group.matches[i];
      final isLastMatch = i == widget.group.matches.length - 1;
      
      if (i > 0) {
        children.add(const Divider(color: Colors.white12, height: 1));
      }
      
      final matchItem = MatchItem(
        match: match,
        onTap: () async {
          final matchId = match.matchId;
          if (matchId == null) return;
          final navigator = Navigator.of(context);
          await Provider.of<MatchProvider>(context, listen: false).fetchMatchDetails(matchId);
          if (!mounted) return;
          navigator.push(
            MaterialPageRoute(builder: (_) => DetailsPage(matchId: matchId)),
          );
        },
      );
      
      // Wrap last match with ClipRRect to add bottom border radius
      if (isLastMatch) {
        children.add(
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(kLeagueTileBorderRadius)),
            child: matchItem,
          ),
        );
      } else {
        children.add(matchItem);
      }
    }
    return children;
  }
}

class LeagueHeaderWidget extends StatelessWidget {
  final League league;
  final String? country;
  final String? countryFlag;
  final int matchCount;

  const LeagueHeaderWidget({
    super.key,
    required this.league,
    this.country,
    this.countryFlag,
    required this.matchCount,
  });

  @override
  Widget build(BuildContext context) {
    final leagueName = league.name?.trim().isNotEmpty == true ? league.name! : 'Unknown League';
    final countryName = country?.trim().isNotEmpty == true ? country! : 'Unknown';
    final headerText = '$countryName - $leagueName';

    return Container(
      height: 50.0,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: CountryFlagHelper.buildCountryFlag(flagUrl: countryFlag, countryName: country),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              headerText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$matchCount matches',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class MatchItem extends StatelessWidget {
  final Matchlist match;
  final VoidCallback onTap;
  final bool showNotificationBell;

  const MatchItem({
    super.key,
    required this.match,
    required this.onTap,
    this.showNotificationBell = false,
  });

  MatchState _getMatchState() {
    final matchStatus = match.status?.trim().toUpperCase() ?? '';
    if (matchStatus == 'FINISHED' || match.isFinished) {
      return MatchState.finished;
    } else if (matchStatus == 'LIVE' || match.isLive) {
      return MatchState.live;
    } else if (matchStatus == 'PRE_MATCH' || match.isUpcoming) {
      return MatchState.scheduled;
    } else {
      return MatchState.scheduled; // default
    }
  }

  Widget _buildLeftWidget(MatchState state) {
    switch (state) {
      case MatchState.scheduled:
        return const SizedBox(width: kMatchStateWidth, height: kMatchStateWidth);
      case MatchState.live:
        return Container(
          width: kMatchStateWidth,
          height: kMatchStateWidth,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            '${match.elapsed ?? 0}\'',
            style: const TextStyle(
              color: Colors.white,
              fontSize: kMatchStateFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case MatchState.finished:
        return Container(
          width: kMatchStateWidth,
          height: kMatchStateWidth,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text(
            'FT',
            style: TextStyle(
              color: Colors.white,
              fontSize: kMatchStateFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  Widget _buildTeamSegment({
    required String? teamName,
    required String? logoUrl,
    required bool isHome,
  }) {
    return Expanded(
      flex: 3,
      child: Row(
        mainAxisAlignment:
            isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isHome
            ? [
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    teamName ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: _teamTextStyle,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: kTeamLogoSize,
                  height: kTeamLogoSize,
                  child: _buildTeamLogo(logoUrl),
                ),
              ]
            : [
                SizedBox(
                  width: kTeamLogoSize,
                  height: kTeamLogoSize,
                  child: _buildTeamLogo(logoUrl),
                ),
                const SizedBox(width: 4),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    teamName ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: _teamTextStyle,
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildScoreSegment(String text, TextStyle style) {
    return SizedBox(
      width: kScoreBoxWidth,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildNotificationSegment() {
    return SizedBox(
      width: kNotificationWidth,
      child: Align(
        alignment: Alignment.centerRight,
        child: showNotificationBell
            ? const Icon(
                Icons.notifications_none,
                color: Colors.white54,
                size: 14,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  static const TextStyle _teamTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
  );

  (String, TextStyle) _getCenterTextAndStyle(MatchState state) {
    switch (state) {
      case MatchState.scheduled:
        final text = match.displayMatchTime.trim().isNotEmpty ? match.displayMatchTime : '';
        final style = const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          fontFamily: 'Roboto',
        );
        return (text, style);
      case MatchState.live:
      case MatchState.finished:
        final text = (match.homeScore != null && match.awayScore != null)
            ? '${match.homeScore} - ${match.awayScore}'
            : '--';
        final style = const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          fontFamily: 'Roboto',
        );
        return (text, style);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _getMatchState();
    final leftWidget = _buildLeftWidget(state);
    final (centerText, centerStyle) = _getCenterTextAndStyle(state);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: kItemHorizontalPadding, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: kMatchStateWidth,
              child: Align(alignment: Alignment.centerLeft, child: leftWidget),
            ),
            const SizedBox(width: kGap),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTeamSegment(
                    teamName: match.homeTeam,
                    logoUrl: match.homeLogo,
                    isHome: true,
                  ),
                  const SizedBox(width: kGap),
                  _buildScoreSegment(centerText, centerStyle),
                  const SizedBox(width: kGap),
                  _buildTeamSegment(
                    teamName: match.awayTeam,
                    logoUrl: match.awayLogo,
                    isHome: false,
                  ),
                ],
              ),
            ),
            const SizedBox(width: kGap),
            _buildNotificationSegment(),
          ],
        ),
      ),
    );
  }
}


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Provider/match.dart';
import 'countdown.dart';

class MatchHeader extends StatelessWidget {
  final MatchProvider match;
  const MatchHeader({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = match.singleMatchData!;
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.h,
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _teamCircle(data.homeLogo),
                      SizedBox(height: 4.h),
                      Text(
                        data.homeTeam ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                _centerBlock(data),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _teamCircle(data.awayLogo),
                      SizedBox(height: 4.h),
                      Text(
                        data.awayTeam ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _teamCircle(String? logo) => Container(
        height: 50.h,
        width: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.r,
          ),
        ),
        padding: EdgeInsets.all(6.r),
        child: logo != null && logo.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logo,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Icon(
                  Icons.sports_soccer,
                  color: Colors.white38,
                  size: 24.sp,
                ),
              )
            : Icon(
                Icons.sports_soccer,
                color: Colors.white38,
                size: 24.sp,
              ),
      );

  Widget _centerBlock(dynamic data) {
    // data should provide matchTime, isUpcoming, homeScore/awayScore, status
    final matchStart = data.matchTime != null ? DateTime.tryParse(data.matchTime) : null;
    final isUpcoming = data.isUpcoming;
    final isLive = data.status != null && data.status.toString().isNotEmpty &&
        // reuse matchstatus from original file by passing formatted string in parent if needed
        false;

    final timeToStart = matchStart != null ? matchStart.toLocal().difference(DateTime.now()) : Duration.zero;
    final countdownDuration = timeToStart.isNegative ? Duration.zero : timeToStart;
    final showCountdown = isUpcoming && matchStart != null && countdownDuration > Duration.zero;

    return Container(
      width: 112.w,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // top label (LIVE or match time)
          SizedBox(height: 4.h),
          SizedBox(height: 8.h),
          if (showCountdown && matchStart != null)
            Center(child: HourMinuteCountdown(endTime: matchStart, showZeroValue: true))
          else
            Text(
              '${data.homeScore ?? 0} - ${data.awayScore ?? 0}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.25,
              ),
            ),
        ],
      ),
    );
  }
}

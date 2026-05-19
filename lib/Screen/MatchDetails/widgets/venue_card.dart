import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VenueCard extends StatelessWidget {
  final String? venueName;
  final String? venueCity;
  const VenueCard({Key? key, this.venueName, this.venueCity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasVenueName = (venueName?.isNotEmpty ?? false);
    final hasVenueCity = (venueCity?.isNotEmpty ?? false);
    if (!hasVenueName && !hasVenueCity) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.stadium,
            color: Colors.white,
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasVenueName)
                  Text(
                    venueName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (hasVenueCity) ...[
                  SizedBox(height: 4.h),
                  Text(
                    venueCity!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.location_on,
            color: Colors.white54,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}

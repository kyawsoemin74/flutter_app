import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OddsThreeWayOption {
  final String label;
  final String odd;
  final bool enabled;

  OddsThreeWayOption({required this.label, required this.odd, this.enabled = true});
}

class OddsThreeWay extends StatelessWidget {
  final List<OddsThreeWayOption> options;
  final Color accentColor;

  const OddsThreeWay({
    Key? key,
    required this.options,
    this.accentColor = const Color(0xFF8A6EFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        return Expanded(
          child: Container(
            height: 44.h,
            margin: EdgeInsets.only(right: option == options.last ? 0 : 6.w),
            decoration: BoxDecoration(
              color: option.enabled ? const Color(0xFF111111) : const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFF222222)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.label,
                  style: TextStyle(
                    color: option.enabled ? Colors.white70 : Colors.white38,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  option.odd,
                  style: TextStyle(
                    color: option.enabled ? accentColor : Colors.white54,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

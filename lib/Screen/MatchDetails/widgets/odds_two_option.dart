import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OddsTwoOptionItem {
  final String label;
  final String odd;
  final bool enabled;

  OddsTwoOptionItem({required this.label, required this.odd, this.enabled = true});
}

class OddsTwoOption extends StatelessWidget {
  final List<OddsTwoOptionItem> options;
  final Color accentColor;

  const OddsTwoOption({
    Key? key,
    required this.options,
    this.accentColor = const Color(0xFF5DD46A),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paddedOptions = options.length >= 2 ? options : [...options, OddsTwoOptionItem(label: '-', odd: '-', enabled: false)];
    return Row(
      children: paddedOptions.take(2).map((item) {
        return Expanded(
          child: Container(
            height: 44.h,
            margin: EdgeInsets.only(right: item == paddedOptions.take(2).last ? 0 : 6.w),
            decoration: BoxDecoration(
              color: item.enabled ? const Color(0xFF111111) : const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFF222222)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: item.enabled ? Colors.white70 : Colors.white38,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.odd,
                  style: TextStyle(
                    color: item.enabled ? accentColor : Colors.white54,
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

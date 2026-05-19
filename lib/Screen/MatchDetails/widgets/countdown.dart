import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Small countdown widget that displays only HH:MM with leading zeros and updates in real time.
class HourMinuteCountdown extends StatefulWidget {
  final DateTime endTime;
  final bool showZeroValue;
  const HourMinuteCountdown({Key? key, required this.endTime, this.showZeroValue = true}) : super(key: key);

  @override
  _HourMinuteCountdownState createState() => _HourMinuteCountdownState();
}

class _HourMinuteCountdownState extends State<HourMinuteCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _startTimer();
  }

  void _updateRemaining() {
    final rem = widget.endTime.toLocal().difference(DateTime.now());
    setState(() {
      _remaining = rem.isNegative ? Duration.zero : rem;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    // Update every second to keep accuracy, but display shows only HH:MM.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
      if (_remaining <= Duration.zero) {
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HourMinuteCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _updateRemaining();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final display = '${_two(hours)}:${_two(minutes)}';

    return Text(
      display,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

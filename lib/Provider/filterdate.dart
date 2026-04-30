import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterDateProvider extends ChangeNotifier {
  List<DateTime> datetime = [];
  TabController? tabController;

  void generatetab(DateTime dateTime) {
    datetime.clear();
    datetime = List.generate(
      7,
      (index) =>
          DateTime(dateTime.year, dateTime.month, dateTime.day - 3 + index),
    );

    notifyListeners();
  }

  void addtabcontroller(TabController tabControllers) {
    tabController = tabControllers;
    notifyListeners();
  }
}

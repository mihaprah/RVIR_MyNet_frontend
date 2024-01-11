import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class CommoditiesProvider extends ChangeNotifier {
  List<double> _goldList = [];
  List<double> _silverList = [];
  List<double> _platinumList = [];
  Map<String, double> _commoditiesMaxValues = {};

  List<double> get goldList => _goldList;
  List<double> get silverList => _silverList;
  List<double> get platinumList => _platinumList;
  Map<String, double> get commoditiesMaxValues => _commoditiesMaxValues;

  void setYearlyList(List<double> list, String code) {
    for (int i = 0; i < list.length; i++) {
      if(list[i] > 0){
        list[i] = 1 / list[i];
      }
    }

    if (code == "XAG") {
      _silverList = list;
    } else if (code == "XAU") {
      _goldList = list;
    } else {
      _platinumList = list;
    }
    setMaximumValues(list, code);
  }

  void setMaximumValues(List<double> list, String code) {
    double maxAmount = 0.0;
    list.forEach((element) {
      if (element > maxAmount) {
        maxAmount = element;
      }
    });
    _commoditiesMaxValues[code] = (maxAmount*1.2).toInt().toDouble();
  }

  List<FlSpot> getYearChartData(List<double> list) {
    List<FlSpot> monthlyList = [];
    double monthlyAverage = 0.0;
    int count = 0;

    for (int i = 0; i < 366; i++) {
      monthlyAverage += list[i];
      count++;

      if ((i + 1) % 30 == 0) {
        int monthIndex = ((i + 1) / 30).floor() - 1;
        monthlyList.add(FlSpot(monthIndex.toDouble(), (monthlyAverage / count)));
        monthlyAverage = 0.0;
        count = 0;
      }
    }

    return monthlyList;
  }

}
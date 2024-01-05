import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/PolygonApiResponse.dart';

class StocksProvider extends ChangeNotifier {
  List<PolygonApiResponse> _appleList = [];
  List<PolygonApiResponse> _teslaList = [];
  List<PolygonApiResponse> _microsoftList = [];
  Map<String, double> _stocksMaxValues = {};

  List<PolygonApiResponse> get appleList => _appleList;
  List<PolygonApiResponse> get teslaList => _teslaList;
  List<PolygonApiResponse> get microsoftList => _microsoftList;
  Map<String, double> get stocksMaxValues => _stocksMaxValues;

  void setYearlyList(List<PolygonApiResponse> list, String code) {
    if (code == "MSFT") {
      _microsoftList = list;
    } else if (code == "AAPL") {
      _appleList = list;
    } else {
      _teslaList = list;
    }
    setMaximumValues(list, code);
  }

  void setMaximumValues(List<PolygonApiResponse> list, String code) {
    double maxAmount = 0.0;
    list.forEach((element) {
      if (element.c > maxAmount) {
        maxAmount = element.c;
      }
    });
    _stocksMaxValues[code] = (maxAmount*1.2).toInt().toDouble();
  }

  List<FlSpot> getYearChartData(List<PolygonApiResponse> list) {
    List<FlSpot> monthlyList = [];
    double monthlyAverage = 0.0;
    int count = 0;

    for (int i = 0; i < 252; i++) {
      monthlyAverage += list[i].c;
      count++;

      if ((i + 1) % 21 == 0) {
        int monthIndex = ((i + 1) / 21).floor() - 1;
        monthlyList.add(FlSpot(monthIndex.toDouble(), (monthlyAverage / count)));
        monthlyAverage = 0.0;
        count = 0;
      }
    }

    return monthlyList;
  }

}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/PolygonApiResponse.dart';

class CryptoProvider extends ChangeNotifier {
  List<PolygonApiResponse> _bitcoinList = [];
  List<PolygonApiResponse> _solanaList = [];
  List<PolygonApiResponse> _etheriumList = [];
  Map<String, double> _cryptoMaxValues = {};

  List<PolygonApiResponse> get bitcoinList => _bitcoinList;
  List<PolygonApiResponse> get solanaList => _solanaList;
  List<PolygonApiResponse> get etheriumList => _etheriumList;
  Map<String, double> get cryptoMaxValues => _cryptoMaxValues;

  void setYearlyList(List<PolygonApiResponse> list, String code) {
    if (code == "ETH") {
      _etheriumList = list;
    } else if (code == "BTC") {
      _bitcoinList = list;
    } else {
      _solanaList = list;
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
    _cryptoMaxValues[code] = (maxAmount*1.2).toInt().toDouble();
  }

  List<FlSpot> getYearChartData(List<PolygonApiResponse> list, double conversionRate) {
    List<FlSpot> monthlyList = [];
    double monthlyAverage = 0.0;
    int count = 0;

    for (int i = 0; i < 366; i++) {
      monthlyAverage += list[i].c;
      count++;

      if ((i + 1) % 30 == 0) {
        int monthIndex = ((i + 1) / 30).floor() - 1;
        monthlyList.add(FlSpot(monthIndex.toDouble(), ((monthlyAverage / count) * conversionRate)));
        monthlyAverage = 0.0;
        count = 0;
      }
    }

    return monthlyList;
  }

}
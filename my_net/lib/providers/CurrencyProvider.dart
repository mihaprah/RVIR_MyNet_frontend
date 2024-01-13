import 'package:flutter/material.dart';

class CurrencyProvider extends ChangeNotifier {
  double _usdToEurConversion = 0.0;

  double get usdToEurConversion => _usdToEurConversion;

  void setConversion(double rate) {
    _usdToEurConversion = rate;
    notifyListeners();
  }

  Future<void> updateRate(double newRate) async {
    _usdToEurConversion = newRate;
    notifyListeners();
  }
}

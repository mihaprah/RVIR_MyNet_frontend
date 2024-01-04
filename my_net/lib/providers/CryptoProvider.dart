import 'package:flutter/material.dart';

import '../models/CryptoApiResponse.dart';

class CryptoProvider extends ChangeNotifier {
  List<CryptoApiResponse> _bitcoinList = [];
  List<CryptoApiResponse> _solanaList = [];
  List<CryptoApiResponse> _etheriumList = [];

  List<CryptoApiResponse> get bitcoinList => _bitcoinList;
  List<CryptoApiResponse> get solanaList => _solanaList;
  List<CryptoApiResponse> get etheriumList => _etheriumList;

  void setYearlyList(List<CryptoApiResponse> list, String code) {
    if (code == "ETH") {
      _etheriumList = list;
    } else if (code == "BTC") {
      _bitcoinList = list;
    } else {
      _solanaList = list;
    }
  }
}
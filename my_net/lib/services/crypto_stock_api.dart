import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_net/models/CryptoApiResponse.dart';
import 'package:provider/provider.dart';

import '../providers/CryptoProvider.dart';

class CryptoStockApiService {
  final String apiKey = "BwrD3yvvWwm_VnpqgjVVt5TyRn5WI1LI";

  Future<void> getYearlyCrypto(String code, BuildContext context) async {
    try {
      CryptoProvider cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
      String endDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      String startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 366)));
      String symbol = "X:${code}USD";

      final Uri uri = Uri.parse(
          'https://api.polygon.io/v2/aggs/ticker/$symbol/range/1/day/$startDate/$endDate?apiKey=$apiKey');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<CryptoApiResponse> results = (responseData['results'] as List<dynamic>)
            .map((data) => CryptoApiResponse.fromJson(data))
            .toList();

        if (results.isNotEmpty) {
          cryptoProvider.setYearlyList(results, code);
        }

      } else {
        print('Error 1: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error 2: $error');
    }

  }
}

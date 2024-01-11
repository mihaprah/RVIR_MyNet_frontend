import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_net/providers/CommoditiesProvider.dart';
import 'package:provider/provider.dart';

class CommoditiesApiService {
  final String apiKeyCommodities = "c1af6c43674efd27bfa60d17b40c7cfe";

  Future<void> getYearlyCommodities(String code, BuildContext context) async {
    try {
      CommoditiesProvider commoditiesProvider = Provider.of<CommoditiesProvider>(context, listen: false);
      String endDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      String startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 366)));

      final Uri uri = Uri.parse(
          'https://api.metalpriceapi.com/v1/timeframe?start_date=$startDate&end_date=$endDate&api_key=$apiKeyCommodities&base=EUR&currencies=$code');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        Map<String, dynamic> ratesMap = jsonData['rates'];

        List<double> results = ratesMap.values
            .map((dateData) {
          if (dateData != null && dateData is Map && dateData.isEmpty) {
            return 0.0;
          } else if (dateData != null && dateData[code] is num) {
            return (dateData[code] as num).toDouble();
          } else {
            return 0.0;
          }
        }).toList();

        if (results.isNotEmpty) {
          commoditiesProvider.setYearlyList(results, code);
        }

      } else {
        print("Error Commodities $code 1: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error Commodities $code 2: $e");
    }

  }
}

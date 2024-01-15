import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_net/models/PolygonApiResponse.dart';
import 'package:my_net/providers/StocksProvider.dart';
import 'package:provider/provider.dart';

class StockApiService {
  final String apiKeyStocks = "f9xUezlI5zGizyYwA59t36eT7d_Sz1oi";

  Future<void> getYearlyStocks(String code, BuildContext context) async {
    try {
      StocksProvider stocksProvider = Provider.of<StocksProvider>(context, listen: false);
      String endDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      String startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 366)));

      final Uri uri = Uri.parse(
          'https://api.polygon.io/v2/aggs/ticker/$code/range/1/day/$startDate/$endDate?limit=400&apiKey=$apiKeyStocks');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<PolygonApiResponse> results = (responseData['results'] as List<dynamic>)
            .map((data) => PolygonApiResponse.fromJson(data))
            .toList();

        if (results.isNotEmpty) {
          stocksProvider.setYearlyList(results, code);
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Stocks prices could not be loaded properly."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stocks prices could not be loaded properly."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

  }
}

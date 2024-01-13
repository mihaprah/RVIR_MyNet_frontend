import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:my_net/providers/CurrencyProvider.dart';
import 'package:provider/provider.dart';

class CurrencyApiService {
  final String apiKeyCurrency = "c1af6c43674efd27bfa60d17b40c7cfe";

  Future<void> getCurrencyConversion(String code, BuildContext context) async {
    try {
      CurrencyProvider currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);

      final Uri uri = Uri.parse(
          'https://api.metalpriceapi.com/v1/latest?api_key=$apiKeyCurrency&base=USD&currencies=$code');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        double? rate = jsonData["rates"]["EUR"];


        if (rate != null) {
          currencyProvider.setConversion(rate);
        }

      } else {
        print("Error Currency $code 1: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error Currency $code 2: $e");
    }

  }
}

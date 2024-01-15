import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_net/providers/CurrencyProvider.dart';
import 'package:provider/provider.dart';

class CurrencyApiService {
  final String apiKeyCurrency = "d7db8a66edce0a2f45bab3bbc6a67566";

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Currency conversion rates could not be loaded properly."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Currency conversion rates could not be loaded properly."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

  }
}

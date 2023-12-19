import 'dart:convert';
import 'package:http/http.dart' as http;

class MetalsApi {
  final String baseUrl =
      "https://api.metalpriceapi.com/v1/latest?api_key=c1af6c43674efd27bfa60d17b40c7cfe&base=EUR&currencies=XAU,XAG,XPT";

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final Map<String, double> rates =
          Map<String, double>.from(jsonData['rates'] ?? {});
      return rates;
    } else {
      throw Exception('Failed to load data');
    }
  }
}

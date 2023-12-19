import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CryptoStockApiService {
  final String apiKey = "BwrD3yvvWwm_VnpqgjVVt5TyRn5WI1LI";

  Future<double?> getPrice(String symbol) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: 1)));

      final Uri uri = Uri.parse(
          'https://api.polygon.io/v2/aggs/ticker/$symbol/range/1/day/$formattedDate/$formattedDate?apiKey=$apiKey');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        //extracting the price information from the response
        final List<dynamic> results = responseData['results'];
        if (results.isNotEmpty) {
          return results[0]['c']?.toDouble();
        }
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }

    return null;
  }
}

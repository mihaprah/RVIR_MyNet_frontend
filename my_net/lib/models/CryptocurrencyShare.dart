import 'Client.dart';
import 'Cryptocurrency.dart';

class CryptocurrencyShare {
  final int? id;
  final double amount;
  final Client client;
  final Cryptocurrency cryptocurrency;

  CryptocurrencyShare({
    this.id,
    required this.amount,
    required this.client,
    required this.cryptocurrency,
  });

  factory CryptocurrencyShare.fromJson(Map<String, dynamic> json) {
    return CryptocurrencyShare(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? 0.0,
      client: Client.fromJson(json['client'] ?? {}),
      cryptocurrency: Cryptocurrency.fromJson(json['cryptocurrency'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'client': client.toJson(),
      'cryptocurrency': cryptocurrency.toJson(),
    };
  }
}

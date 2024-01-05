import 'Client.dart';
import 'Stock.dart';

class StockShare {
  final int? id;
  final double amount;
  final Client client;
  final Stock stock;

  StockShare({
    this.id,
    required this.amount,
    required this.client,
    required this.stock,
  });

  factory StockShare.fromJson(Map<String, dynamic> json) {
    return StockShare(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? 0.0,
      client: Client.fromJson(json['client'] ?? {}),
      stock: Stock.fromJson(json['stock'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'client': client.toJson(),
      'stock': stock.toJson(),
    };
  }
}

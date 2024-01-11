import 'Commodity.dart';
import 'Client.dart';

class CommodityShare {
  final int? id;
  final double amount;
  final Client client;
  final Commodity commodity;

  CommodityShare({
    this.id,
    required this.amount,
    required this.client,
    required this.commodity,
  });

  factory CommodityShare.fromJson(Map<String, dynamic> json) {
    return CommodityShare(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? 0.0,
      client: Client.fromJson(json['client'] ?? {}),
      commodity: Commodity.fromJson(json['commodity'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'client': client.toJson(),
      'commodity': commodity.toJson(),
    };
  }
}

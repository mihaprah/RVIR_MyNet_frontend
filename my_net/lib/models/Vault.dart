import 'Client.dart';

class Vault {
  final int? id;
  final String name;
  final double goal;
  final double amount;
  final DateTime dueDate;
  final Client client;

  Vault({
    this.id,
    required this.name,
    required this.goal,
    required this.amount,
    required this.dueDate,
    required this.client,
  });

  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      goal: json['goal'] ?? 0.0,
      amount: json['amount'] ?? 0.0,
      dueDate: DateTime.parse(json['dueDate'] ?? ''),
      client: Client.fromJson(json['client'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'client': client.toJson(),
    };
  }
}

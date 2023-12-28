import 'Client.dart';

class Vault {
  final int? id;
  final String name;
  final double goal;
  final double amount;
  final DateTime dueDate;
  final String icon;
  final Client client;

  Vault({
    this.id,
    required this.name,
    required this.goal,
    required this.amount,
    required this.dueDate,
    required this.icon,
    required this.client,
  });

  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      goal: json['goal'] ?? 0.0,
      amount: json['amount'] ?? 0.0,
      dueDate: DateTime.parse(json['dueDate'] ?? ''),
      icon: json['icon'] ?? '',
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
      'icon': icon,
      'client': client.toJson(),
    };
  }
}

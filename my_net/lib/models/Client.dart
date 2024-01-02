import 'Vault.dart';

class Client {
  final int? id;
  final String name;
  final String lastname;
  final double cashBalance;
  final String email;
  final String password;
  final String salt;
  final List<Vault> vaults;

  Client({
    this.id,
    required this.name,
    required this.lastname,
    required this.cashBalance,
    required this.email,
    required this.password,
    required this.salt,
    required this.vaults,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      cashBalance: json['cashBalance'] ?? 0.0,
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      salt: json['salt'] ?? '',
      vaults: (json['vaults'] as List<dynamic>?)
              ?.map((vaultJson) => Vault.fromJson(vaultJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'cashBalance': cashBalance,
      'email': email,
      'password': password,
      'salt': salt,
      'vaults': vaults.map((vault) => vault.toJson()).toList(),
    };
  }
}

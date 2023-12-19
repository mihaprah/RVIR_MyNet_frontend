class Cryptocurrency {
  final int id;
  final String name;
  final String code;

  Cryptocurrency({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Cryptocurrency.fromJson(Map<String, dynamic> json) {
    return Cryptocurrency(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

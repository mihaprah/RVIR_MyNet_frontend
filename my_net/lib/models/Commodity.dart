class Commodity {
  final int id;
  final String name;
  final String code;

  Commodity({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
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

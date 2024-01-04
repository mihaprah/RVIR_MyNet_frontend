class CryptoApiResponse {
  final double c;
  final double h;
  final double l;
  final int n;
  final double o;
  final int t;
  final double v;
  final double vw;

  CryptoApiResponse({
    required this.c,
    required this.h,
    required this.l,
    required this.n,
    required this.o,
    required this.t,
    required this.v,
    required this.vw,
  });

  factory CryptoApiResponse.fromJson(Map<String, dynamic> json) {
    return CryptoApiResponse(
        c: (json['c'] as num).toDouble(),
        h: (json['h'] as num).toDouble(),
        l: (json['l'] as num).toDouble(),
        n: json['n'] as int,
        o: (json['o'] as num).toDouble(),
        t: json['t'] as int,
        v: (json['v'] as num).toDouble(),
        vw: (json['vw'] as num).toDouble());
  }
}
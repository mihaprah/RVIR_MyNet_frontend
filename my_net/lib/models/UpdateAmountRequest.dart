class UpdateAmountRequest {
  final double amount;

  UpdateAmountRequest({
    required this.amount,
  });

  factory UpdateAmountRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAmountRequest(
      amount: json['amount'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
    };
  }
}

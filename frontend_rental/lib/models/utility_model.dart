class UtilityModel {
  final String utilityType; // e.g. 'electricity', 'water', 'gas'
  final String billingType; // e.g. 'fixed', 'per_unit'
  final String amount;

  UtilityModel({
    required this.utilityType,
    required this.billingType,
    required this.amount,
  });

  factory UtilityModel.fromJson(Map<String, dynamic> json) {
    return UtilityModel(
      utilityType: json['utility_type'],
      billingType: json['billing_type'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'utility_type': utilityType,
      'billing_type': billingType,
      'amount': amount,
    };
  }
}

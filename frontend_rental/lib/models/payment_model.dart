class PaymentModel {
  final int? id;
  final String leaseId;
  final String paymentDate;
  final double amountPaid;
  final String paymentMethodId;
  final String receiptUrl;
  final String? electricity;
  final String? water;

  PaymentModel({
    this.id,
    required this.leaseId,
    required this.paymentDate,
    required this.amountPaid,
    required this.paymentMethodId,
    required this.receiptUrl,
    this.electricity,
    this.water
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      leaseId: json['lease_id'],
      paymentDate: json['payment_date'],
      amountPaid: (json['amount_paid'] as num).toDouble(),
      paymentMethodId: json['payment_method_id'],
      receiptUrl: json['receipt_url'],
      electricity: json['electricity'],
      water: json['water'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lease_id': leaseId,
      'payment_date': paymentDate,
      'amount_paid': amountPaid,
      'payment_method_id': paymentMethodId,
      'receipt_url': receiptUrl,
      'electricity': electricity,
      'water': water
    };
  }
}

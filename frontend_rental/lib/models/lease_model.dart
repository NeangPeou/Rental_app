class LeaseModel {
  final int? id;
  final int unitId;
  final int renterId;
  final String startDate;
  final String endDate;
  final double rentAmount;
  final double? depositAmount;
  final String status;
  final String? username;

  LeaseModel({
    this.id,
    required this.unitId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    this.depositAmount,
    required this.status,
    this.username,
  });

  factory LeaseModel.fromJson(Map<String, dynamic> json) {
    return LeaseModel(
      id: json['id'],
      unitId: json['unit_id'] ?? 0,
      renterId: json['renter_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      rentAmount: (json['rent_amount'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
      status: json['status'] ?? '',
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'renter_id': renterId,
      'start_date': startDate,
      'end_date': endDate,
      'rent_amount': rentAmount,
      'deposit_amount': depositAmount,
      'status': status,
    };
  }
}
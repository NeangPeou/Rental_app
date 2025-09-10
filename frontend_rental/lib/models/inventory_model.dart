class InventoryModel {
  final int? id;
  final int unitId;
  final String item;
  final int qty;
  final String condition;

  InventoryModel({
    this.id,
    required this.unitId,
    required this.item,
    required this.qty,
    required this.condition,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      unitId: json['unit_id'] ?? 0,
      item: json['item'] ?? '',
      qty: json['qty'] ?? 1,
      condition: json['condition'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'item': item,
      'qty': qty,
      'condition': condition,
    };
  }
}
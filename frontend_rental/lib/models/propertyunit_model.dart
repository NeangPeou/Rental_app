class PropertyUnitModel {
  final int? id;
  final String unitNumber;
  final String? floor;
  final String? bedrooms;
  final String? bathrooms;
  final String? size;
  final String? rent;
  final bool isAvailable;
  final String propertyId;

  PropertyUnitModel({
    this.id,
    required this.unitNumber,
    this.floor,
    this.bedrooms,
    this.bathrooms,
    this.size,
    this.rent,
    required this.isAvailable,
    required this.propertyId,
  });

  factory PropertyUnitModel.fromJson(Map<String, dynamic> json) {
    return PropertyUnitModel(
      id: json['id'],
      unitNumber: json['unit_number'] ?? '',
      floor: json['floor']?.toString(),
      bedrooms: json['bedrooms']?.toString(),
      bathrooms: json['bathrooms']?.toString(),
      size: json['size']?.toString(),
      rent: json['rent']?.toString(),
      isAvailable: json['is_available'] ?? false,
      propertyId: json['property_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "unit_number": unitNumber,
      "floor": floor,
      "bedrooms": bedrooms,
      "bathrooms": bathrooms,
      "size": size,
      "rent": rent,
      "is_available": isAvailable,
      "property_id": propertyId,
    };
  }
}
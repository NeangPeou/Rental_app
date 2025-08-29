class PropertyModel {
  final int? id;
  final String name;
  final String address;
  final String city;
  final String? district;
  final String? province;
  final String? postalCode;
  final String? latitude;
  final String? longitude;
  final String? description;
  final String typeId;
  final String ownerId;
  final List<String>? images;

  PropertyModel({
    this.id,
    required this.name,
    required this.address,
    required this.city,
    this.district,
    this.province,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.description,
    required this.typeId,
    required this.ownerId,
    this.images,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    city: json['city'],
    district: json['district'],
    province: json['province'],
    postalCode: json['postal_code'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    description: json['description'] ?? '',
    typeId: json['type_id'],
    ownerId: json['owner_id'],
    images: List<String>.from(json['images'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'city': city,
    'district': district,
    'province': province,
    'postal_code': postalCode,
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
    'type_id': typeId,
    'owner_id': ownerId,
    'images': images,
  };
}

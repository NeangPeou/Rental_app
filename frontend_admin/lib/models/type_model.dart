class TypeModel {
  final int id;
  final String typeCode;
  final String name;

  TypeModel({
    required this.id,
    required this.typeCode,
    required this.name,
  });

  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(
      id: json['id'],
      typeCode: json['type_code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeCode': typeCode,
      'name': name,
    };
  }
}

class UserModel {
  final int? id;
  final String userName;
  final String? userID;
  final String password;
  final String phoneNumber;
  final String? passport;
  final String? idCard;
  final String? address;
  final String? status;

  UserModel({
    this.id,
    required this.userName,
    this.userID,
    required this.password,
    required this.phoneNumber,
    this.passport,
    this.idCard,
    this.address,
    this.status = 'Active',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userName: json['userName']?.toString() ?? '',
      userID: json['userID']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      passport: json['passport']?.toString() ?? '',
      idCard: json['idCard']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

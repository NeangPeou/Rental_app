class UserModel {
  final String? id;
  final String userName;
  final String? userID;
  final String password;
  final String phoneNumber;
  final String? passport;
  final String? idCard;
  final String? address;
  final String? gender;
  final String? status;
  final String? accessToken;
  final String? refreshToken;

  UserModel({
    this.id,
    required this.userName,
    this.userID,
    required this.password,
    required this.phoneNumber,
    this.passport,
    this.idCard,
    this.address,
    this.gender = 'Male',
    this.status = 'Active',
    this.accessToken,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userID: json['userID']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      passport: json['passport']?.toString() ?? '',
      idCard: json['idCard']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      gender: ['Male', 'Female'].contains(json['gender']?.toString())
        ? json['gender']?.toString()
        : 'Male',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'userID': userID,
    'password': password,
    'phoneNumber': phoneNumber,
    'passport': passport,
    'idCard': idCard,
    'address': address,
    'gender' : gender,
    'status': status,
  };
}

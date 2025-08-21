class SystemLogModel {
  final String id;
  final String userId;
  final String action;
  final String logType;
  final String message;
  final String hostName;
  final String createdAt;
  final String? updatedAt;

  SystemLogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.logType,
    required this.message,
    required this.hostName,
    required this.createdAt,
    this.updatedAt,
  });

  factory SystemLogModel.fromJson(Map<String, dynamic> json) {
    return SystemLogModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      logType: json['logType']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
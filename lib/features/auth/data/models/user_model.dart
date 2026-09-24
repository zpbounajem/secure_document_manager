class UserModel {
  final int id;
  final String firebaseUid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? profileImage;
  final int roleId;
  final String roleName;
  final String status;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.profileImage,
    required this.roleId,
    required this.roleName,
    required this.status,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String?,
      profileImage: json['profile_image'] as String?,
      roleId: json['role_id'] as int,
      roleName: json['role_name'] as String,
      status: json['status'] as String,
      lastLoginAt: _parseDateTime(json['last_login_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'profile_image': profileImage,
      'role_id': roleId,
      'role_name': roleName,
      'status': status,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String get fullName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!;
    }

    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';

    if (first.isNotEmpty && last.isNotEmpty) {
      return '$first $last';
    }

    if (first.isNotEmpty) {
      return first;
    }

    if (last.isNotEmpty) {
      return last;
    }

    return email;
  }
}
import '../../domain/entities/user_entity.dart';

/// Login response model from API
class LoginResponseModel {
  final String message;
  final UserModel data;

  LoginResponseModel({
    required this.message,
    required this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? '',
      data: UserModel.fromJson(json['data'] ?? {}),
    );
  }
}

/// User data model from API response
class UserModel extends UserEntity {
  const UserModel({
    required super.name,
    required super.email,
    required super.phone,
    super.region,
    super.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      region: json['region'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'region': region,
      'profileImage': profileImage,
    };
  }

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      name: name,
      email: email,
      phone: phone,
      region: region,
      profileImage: profileImage,
    );
  }
}


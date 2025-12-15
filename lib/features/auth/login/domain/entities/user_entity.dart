import 'package:equatable/equatable.dart';

/// User entity representing authenticated user data
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? region;
  final String? profileImage;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.region,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, name, email, phone, region, profileImage];
}
